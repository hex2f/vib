module main

import os

fn (c Config) sign_payload() {
	println("Signing payload with entitlements")
	entitlements := os.join_path('Payload', '${c.bundle_name}.entitlements')
	bundle := os.join_path('Payload', '${c.bundle_name}.app')
	os.execute_or_panic('codesign -f --deep --entitlements $entitlements -s "$c.codesign_identity" $bundle')
}
