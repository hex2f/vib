module main

import os

fn main() {
	if os.args.len < 2 || !os.exists(os.args[1]) {
		println("Error: No binary provided. Usage: vib <path to binary>")
		return
	}
	config := config_from_file(os.args[1]) or {
		println("Config parsing failed: $err.msg")
		return
	}
	println(config)
	config.create_bundle()
}