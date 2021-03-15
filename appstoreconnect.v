module main

import os
import net.http

struct ConnectConfig {
mut:
	issuer_id	string
	key_id		string
	key_file	string
	key			[]byte
	jwt			string
}

fn load_connect_config() ?ConnectConfig {
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
	ruby_script_path := os.resource_abs_path('jwt.rb')
	key_path := os.join_path(os.home_dir(), '.vib', c.key_file)
	ruby_jtw := os.execute_or_panic('ISSUER_ID=$c.issuer_id KEY_ID=$c.key_id KEY_PATH=$key_path ruby $ruby_script_path')
	c.jwt = ruby_jtw.output.trim(' \n')

	identity := select_signing_identity() or { panic(err) }
	serial := get_certificate_serial(identity)

	println(c.get('certificates?filter[serialNumber]=$serial'))

	return c
}

fn (c ConnectConfig) get(endpoint string) ?string {
	res := http.fetch('https://api.appstoreconnect.apple.com/v1/$endpoint', {
		method: .get
		headers: { 'Authorization': 'Bearer $c.jwt' }
	}) or { return err }
	return res.text
}