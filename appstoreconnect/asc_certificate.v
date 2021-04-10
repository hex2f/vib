module appstoreconnect

import json

enum CertificateType {
	ios_development
	ios_distribution
	mac_app_distribution
	mac_installer_distribution
	mac_app_development
	developer_id_kext
	developer_id_application
	development
	distribution
}

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
	data 	[]ASCCertificate
	errors 	[]ASCRequestError
}

struct ASCCertificateCreateResponse {
	data 	ASCCertificate
	errors 	[]ASCRequestError
}

struct ASCCertificateCreateData {
	attributes	map[string]string
	typ			string [json: 'type']
}

struct ASCCertificateCreateRequest {
	certificate_type 	CertificateType
	csr_content 		string
}

fn (c ConnectConfig) create_certificate(r ASCCertificateCreateRequest) ASCCertificateCreateResponse {
	json_data := json.encode({
		'data': ASCCertificateCreateData {
			attributes: {
				'certificateType': r.certificate_type.str().to_upper()
				'csrContent': r.csr_content
			}
			typ: 'certificates'
		}
	})

	raw_res := c.fetch(.post, 'certificates', json_data) or { panic(err) }
	return json.decode(ASCCertificateCreateResponse, raw_res) or { panic(err) }
}