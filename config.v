module main

import os
import certificates

struct Config {
mut:
	binary_name				string
	binary_path				string
	bundle_name				string
	bundle_version			string = '1'
	display_name			string
	bundle_id				string
	team_id					string
	codesign_identity  		string
	provisioning_profile	string
}

fn parse_config(s string) Config {
	lines := s.split('\n')
	mut result := Config{}

	for line in lines {
		if line.split('=').len < 2 { continue }
		key := line.split('=')[0]
		value := line.after_char(`=`)

		// TODO: Replace with a generic reflection, like this
		// $for field in T.fields {
		//   if key == field.name { result.$(field.name) = line.after_char(`=`) }
		// }
		match key {
			'bundle_name' { result.bundle_name = value }
			'display_name' { result.display_name = value }
			'bundle_id' { result.bundle_id = value }
			'bundle_version' { result.bundle_version = value }
			'team_id' { result.team_id = value }
			'codesign_identity' { result.codesign_identity = value.replace('"', '') }
			'provisioning_profile' { result.provisioning_profile = os.real_path(value) }
			else  { println('Warning: config contains invalid key "$key"') }
		}
	}

	return result
}

fn config_from_file(binary_path string) ?Config {
	println('Parsing config file')
	file := os.read_file('${binary_path}.vib') or { return error("Couldn't find a config file called \"${binary_path}.vib\"") }
	mut config := parse_config(file)
	
	config.binary_name = binary_path.all_after_last('/')
	config.binary_path = os.real_path(binary_path)
	if config.bundle_name == '' { config.bundle_name = config.binary_name }
	if config.display_name == '' { config.display_name = config.bundle_name }

	if config.codesign_identity.len <= 0 {
		config.codesign_identity = certificates.select_signing_identity() or { return error("No code signing identity selected.") }
	}
	if config.provisioning_profile.len <= 0 || !os.exists(config.provisioning_profile) {
		return error("No valid provisioning profile provided in the config.")
	}
	return config
}