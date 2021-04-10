module main

import os
import appstoreconnect

fn main() {
	if os.args.len < 2 || (!os.exists(os.args[1]) && (os.args[1] != 'provision' && os.args[1] != 'certificate')) {
		println("Error: No binary provided. Usage: vib <path to binary>")
		return
	}
	if os.args[1] == 'provision' {
		connect_config := appstoreconnect.load_connect_config() or { panic(err) }
		connect_config.provision_profile_wizard()
		return
	} else if os.args[1] == 'certificate' {
		connect_config := appstoreconnect.load_connect_config() or { panic(err) }
		connect_config.certificate_wizard()
		return
	}

	config := config_from_file(os.args[1]) or {
		println("Config parsing failed: $err.msg")
		return
	}
	println(config)
	config.create_bundle()
}