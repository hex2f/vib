module certificates

import os
import readline

pub fn select_signing_identity() ?string {
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

pub fn get_certificate_serial(identity string) string {
	raw_res := os.execute_or_panic('security find-certificate -c "$identity"')
	serial := raw_res.output.all_after('"snbr"<blob>=0x').all_before(' ')
	return serial
}

pub fn create_private_key(key string) string {
	os.execute_or_panic('openssl genrsa -out ${key}.key 2048')
	return os.execute_or_panic('cat ${key}.key').output
}

pub fn create_csr(key string, email string, name string) string {
	os.execute_or_panic('openssl req -new -key ${key}.key -out ${key}.csr -subj "/emailAddress=${email}/O=${name}/C=JP"')
	return os.execute_or_panic('cat ${key}.csr').output
}