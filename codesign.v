module main

import os
import readline

fn select_signing_identity() ?string {
	raw_res := os.execute_or_panic('security find-identity -v -p codesigning')
	lines := raw_res.output.split('\n')
	// Dealing with user oriented data, mmm, love it
	identities := lines.filter(it.contains('(')).map( it.all_after('"').all_before_last('"') )
	for i, identity in identities {
		println('${i+1}) $identity')
	}
	selection := readline.read_line('Select an identity: ') or { return error("No valid codesign identity selected.") }
	if selection.int() <= 0 || selection.int() > identities.len { return error("No valid codesign identity selected.") }
	return identities[selection.int() - 1]
}

fn (c Config) sign_payload() {
	println("Signing payload with entitlements")
	entitlements := os.join_path('Payload', '${c.bundle_name}.entitlements')
	bundle := os.join_path('Payload', '${c.bundle_name}.app')
	os.execute_or_panic('codesign -f --deep --entitlements $entitlements -s "$c.codesign_identity" $bundle')
}