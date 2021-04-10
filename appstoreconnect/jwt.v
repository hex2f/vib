module appstoreconnect

// import json
// import time
// import encoding.base64

// struct JWTHeader {
// 	alg string = 'HS256'
// 	kid string
// 	typ string = 'JWT'
// }

// struct JWTPayload {
// 	iss string
// 	exp u64
// 	aud string = "appstoreconnect-v1"
// }

// fn base64urlencode(b []byte) string {
// 	return base64.encode(b).replace('+', '-').replace('/', '_').replace('=', '')
// }

// fn (mut c ConnectConfig) create_jwt() {
// 	jwt_header := base64urlencode(json.encode(JWTHeader {
// 		kid: c.key_id
// 	}).bytes())

// 	exp := time.now().unix + 60 * 5 // now + 5 minutes

// 	jwt_payload := base64urlencode(json.encode(JWTPayload {
// 		iss: c.issuer_id
// 		exp: exp
// 	}).bytes())

// 	sig_payload := "${jwt_header}.${jwt_payload}"

// 	sig := ''.bytes() //TODO: implement crypto.ecdsa

// 	c.jwt = '${jwt_header}.${jwt_payload}.${base64urlencode(sig)}'
// }
