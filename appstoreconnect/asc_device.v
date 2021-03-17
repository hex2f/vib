module appstoreconnect

struct ASCDevice {
	id 			string
	attributes 	ASCDeviceAttributes
}

struct ASCDeviceAttributes {
	platform_name 	string [json: platformName]
	name 			string
	model 			string
	platform		string
}

struct ASCDeviceResponse {
	data []ASCDevice
}