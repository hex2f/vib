module appstoreconnect

import json

// Results
struct ASCProfile {
	id 			string
	attributes 	ASCProfileAttributes
}

struct ASCProfileAttributes {
	profile_state 	string [json: profileState]
	created_date	string [json: createdDate]
	expiration_date	string [json: expirationDate]
	profile_type	string [json: profileType]
	name			string
	profile_content	string [json: profileContent]
	uuid			string
	platform		string

}

struct ASCProfileResponse {
	data 	[]ASCProfile
	errors 	[]ASCRequestError
}

struct ASCProfileCreateResponse {
	data 	ASCProfile
	errors 	[]ASCRequestError
}

enum ProfileType {
	ios_app_development
    ios_app_store
    ios_app_adhoc
    ios_app_inhouse
	// TODO (maybe): Add other bundling types than iOS
    // mac_app_development
    // mac_app_store
    // mac_app_direct
    // tvos_app_development
    // tvos_app_store
    // tvos_app_adhoc
    // tvos_app_inhouse
    // mac_catalyst_app_development
    // mac_catalyst_app_store
    // mac_catalyst_app_direct
}

struct ASCProfileCreateRequest {
	name 			string
	profile_type 	ProfileType
	bundle_id		string
	certificate_id	string
	devices			[]ASCDevice
}

struct ASCProfileCreateData {
	attributes 		map[string]string
	relationships 	ASCProfileCreateRelationships
	typ				string [json: 'type']
}

struct ASCProfileCreateRelationships {
	bundle_id 		map[string]map[string]string [json: bundleId]
	certificates 	map[string][]map[string]string // mmm lovely types
	devices			map[string][]map[string]string
}

fn (c ConnectConfig) create_profile(r ASCProfileCreateRequest) ASCProfileCreateResponse {
	json_data := json.encode({
		'data': ASCProfileCreateData {
			attributes: {
				'name': r.name
				'profileType': r.profile_type.str().to_upper()
			}
			relationships: ASCProfileCreateRelationships {
				bundle_id: {
					'data': {
						'id': r.bundle_id
						'type': 'bundleIds'
					}
				}
				certificates: {
					'data': [
						{ 'id': r.certificate_id, 'type': 'certificates' }
					]
				}
				devices: {
					'data': r.devices.map({ 'id': it.id, 'type': 'devices' })
				}
			}
			typ: 'profiles'
		}
	})

	raw_res := c.fetch(.post, 'profiles', json_data) or { panic(err) }
	return json.decode(ASCProfileCreateResponse, raw_res) or { panic(err) }
}