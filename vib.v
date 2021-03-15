module main

import os

fn main() {
	println(os.args)
	if os.args.len < 2 || (!os.exists(os.args[1]) && os.args[1] != 'provision') {
		println("Error: No binary provided. Usage: vib <path to binary>")
		return
	}
	if os.args[1] == 'provision' {
		connect_config := load_connect_config() or { panic(err) }
		println(connect_config)
		return
	}

	config := config_from_file(os.args[1]) or {
		println("Config parsing failed: $err.msg")
		return
	}
	println(config)
	config.create_bundle()
}