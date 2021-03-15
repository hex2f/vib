module main

import os

fn (c Config) create_bundle() {
	c.create_bundle_folder()
	c.bundle_to_payload()
	c.sign_payload()
	c.package_payload_to_ipa()
}

fn (c Config) create_bundle_folder() {
	println('Creating app bundle')
	// TODO: Support custom output paths
	bundle_dir := '${c.bundle_name}.app'
	if os.exists(bundle_dir) {
		os.rmdir_all(bundle_dir) or { panic('Failed to remove existing bundle directory "$bundle_dir", $err.msg') }
	}
	os.mkdir(bundle_dir) or { panic('Failed to create bundle directory "$bundle_dir", $err.msg') }
	println('Writing PkgInfo to bundle')
	os.write_file(os.join_path(bundle_dir, 'PkgInfo'), 'APPL????') or { panic('Failed to write PkgInfo, $err.msg') }
	println('Generating and writing Info.plist to bundle')
	os.write_file(os.join_path(bundle_dir, 'Info.plist'), generate_info_plist(c)) or { panic('Failed to write Info.plist, $err.msg') }
	println('Writing provisioning profile to bundle')
	os.cp(c.provisioning_profile, os.join_path(bundle_dir, 'embedded.mobileprovision')) or { panic('Failed to copy the provisioning profile into the bundle, $err.msg') }
	println('Writing binary to bundle')
	os.cp(c.binary_path, os.join_path(bundle_dir, c.binary_name)) or { panic('Failed to copy the binary into the bundle, $err.msg') }
}

fn (c Config) bundle_to_payload() {
	// TODO: Support custom output paths
	println('Creating Payload')
	bundle_dir := '${c.bundle_name}.app'
	payload_dir := 'Payload'
	if os.exists(payload_dir) {
		os.rmdir_all(payload_dir) or { panic('Failed to remove existing bundle directory "$payload_dir", $err.msg') }
	}
	os.mkdir(payload_dir) or { panic('Failed to create bundle directory "$payload_dir", $err.msg') }
	println('Moving app bundle to Payload')
	os.mv(bundle_dir, os.join_path(payload_dir, '${c.bundle_name}.app')) or { panic('Failed to move bundle into Payload, $err.msg') }
	println('Generating and writing entitlements file to Payload')
	os.write_file(os.join_path(payload_dir, '${c.bundle_name}.entitlements'), generate_entitlements_plist(c)) or { panic('Failed to write Info.plist, $err.msg') }
}

fn (c Config) package_payload_to_ipa() {
	println('Packaging payload into an ipa')
	os.execute_or_panic('zip -0 -y -r ${c.bundle_name}.ipa Payload/')
}