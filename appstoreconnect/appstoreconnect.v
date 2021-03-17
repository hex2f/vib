module appstoreconnect

import os
import time
import json
import readline
import net.http
import certificates
import encoding.base64

struct ConnectConfig {
mut:
	issuer_id	string
	key_id		string
	key_file	string
	key			[]byte
	jwt			string
}

pub fn load_connect_config() ?ConnectConfig {
	file :=  os.read_file(os.join_path(os.home_dir(), '.vib', 'config.vib')) or {
		return error("Couldn't find a config in ~/.vib")
	}
	lines := file.split('\n')
	mut c := ConnectConfig{}

	for line in lines {
		if line.split('=').len < 2 { continue }
		key := line.split('=')[0]
		value := line.after_char(`=`)

		match key {
			'issuer_id' { c.issuer_id = value }
			'key_id' { c.key_id = value }
			'key_file' { c.key_file = value }
			else  { println('Warning: config contains invalid key "$key"') }
		}
	}

	// TODO: Implement ecdsa sha256 in vlib so we can create JWTs directly in V
	// keylines := os.read_lines(os.join_path(os.home_dir(), '.vib', c.key_file)) or {
	// 	return error("Failed to load the key file.")
	// }
	// keystr := keylines[1..keylines.len-1].join('')
	// c.key = keystr.bytes()
	// c.create_jwt()
	ruby_script_path := os.resource_abs_path('appstoreconnect/jwt.rb')
	key_path := os.join_path(os.home_dir(), '.vib', c.key_file)
	ruby_jtw := os.execute_or_panic('ISSUER_ID=$c.issuer_id KEY_ID=$c.key_id KEY_PATH=$key_path ruby $ruby_script_path')
	c.jwt = ruby_jtw.output.trim(' \n')

	return c
}

fn (c ConnectConfig) error(msg string) {
	println(msg)
	exit(0)
}

struct ASCRequestError {
	id		string
	status 	string
	code	string
	title	string
	detail	string
}

fn (c ConnectConfig) create_bundle_id_wizard(identifier string) ASCBundleId {
	c.create_bundle_id(identifier, identifier.replace('.', ' '), .ios)
	return c.fetch_bundle_id(identifier) or  {panic(err) }
}

pub fn (c ConnectConfig) provision_profile_wizard() {
	println('=== App Store Connect Provisioning Profile wizard ===\n')
	
	raw_bundle_id := readline.read_line('Unique bundle identifier (ex. com.foo.bar): ') or { return }
	bundle_id := c.fetch_bundle_id(raw_bundle_id.trim('\n')) or {
		println("Bundle identifier is not registered in App Store Connect. Creating...")
		c.create_bundle_id_wizard(raw_bundle_id.trim('\n'))
	}
	
	mut found_cert := false
	mut certificate_type := ''
	mut cert_id := ''
	for !found_cert {
		println('')
		identity := certificates.select_signing_identity() or { panic(err) }
		serial := certificates.get_certificate_serial(identity)
		raw_res := c.fetch(.get, 'certificates?filter[serialNumber]=${serial.trim_left('0')}', '') or { panic(err) }
		data := json.decode(ASCCertificateResponse, raw_res) or { panic(err) }
		if data.errors.len > 0 || data.data.len <= 0 {
			println("That identity couldn't be found in App Store Connect. Please select another one.")
		} else {
			cert_id = data.data[0].id
			certificate_type = data.data[0].attributes.certificate_type
			found_cert = true
		}
	}

	mut devices := []ASCDevice{}

	if certificate_type != 'DISTRIBUTION'  {
		println('')
		devices_raw_res := c.fetch(.get, 'devices', '') or { panic(err) }
		devices_data := json.decode(ASCDeviceResponse, devices_raw_res) or { panic(err) }
		for i, device in devices_data.data.filter(it.attributes.platform == 'IOS') {
			if i < 10 { print(' ') }
			println('${i+1}) ${device.attributes.model} - ${device.attributes.name}')
		}
		selected_device := readline.read_line('Select devices (ex. 1,3,7): ') or { return }
		for s in selected_device.split(',') {
			if s.int() < 1 || s.int() > devices_data.data.len {
				continue
			}
			devices << devices_data.data[s.int()-1]
		}
		
	}

	println('')
	profile_name := readline.read_line('Unique profile name: ') or { return }
	profile := c.create_profile({
		name: profile_name
		profile_type: .ios_app_development
		bundle_id: bundle_id.id
		certificate_id: cert_id
		devices: devices
	})

	if profile.errors.len > 0 {
		c.error(profile.errors[0].detail)
	}

	// haha funny
	mut pro_file_name := raw_bundle_id.trim('\n').replace('.', '_')
	
	for os.exists(pro_file_name + '.mobileprovision') {
		pro_file_name += '_'
	}

	os.write_file_array(pro_file_name + '.mobileprovision', base64.decode(profile.data.attributes.profile_content)) or { panic(err) }
	println('\nProvisioning profile saved as "${pro_file_name}.mobileprovision"')
}

fn (c ConnectConfig) fetch(method http.Method, endpoint string, data string) ?string {
	res := http.fetch('https://api.appstoreconnect.apple.com/v1/$endpoint', {
		method: method
		data: data
		headers: { 'Authorization': 'Bearer $c.jwt', 'Content-Type': 'application/json' }
	}) or { return err }
	return res.text
}
