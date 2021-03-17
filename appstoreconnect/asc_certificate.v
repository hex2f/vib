module appstoreconnect

struct ASCCertificate {
	id 			string
	attributes 	ASCCertificateAttributes
}

struct ASCCertificateAttributes {
	serial_number 		string 		[json: serialNumber]
	certificate_content string 		[json: certificateContent]
	display_name		string 		[json: displayName]
	name				string
	expiration_date		string 		[json: expirationDate]
	certificate_type	string 		[json: certificateType]
}

struct ASCCertificateResponse {
	data []ASCCertificate
	errors 	[]ASCRequestError
}