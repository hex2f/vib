module appstoreconnect

import json

enum ASCBundleIdPlatform {
	ios
	mac_os
}

struct ASCBundleIdResponse {
	data	[]ASCBundleId
	errors 	[]ASCRequestError
}

struct ASCBundleIdCreateResponse {
	data	ASCBundleId
	errors 	[]ASCRequestError
}

struct ASCBundleId {
	id			string
	attributes	ASCBundleIdAttributes
}

struct ASCBundleIdAttributes {
	name		string
	identifier	string
	platform	string
	seed_id		string [json: seedId]
}

struct ASCBundleIdCreateRequest {
	attributes 	map[string]string
	typ			string [json: 'type']
}

fn (c ConnectConfig) create_bundle_id(identifier string, name string, platform ASCBundleIdPlatform) ASCBundleIdCreateResponse {
	res_raw := c.fetch(.post, 'bundleIds', json.encode({
		"data": ASCBundleIdCreateRequest {
			attributes: {
				"identifier": identifier,
				"name": name,
				"platform": platform.str().to_upper()
			},
			typ: "bundleIds"
		}
	})) or {
		c.error('Failed to create bundle identifier, $err.msg')
		panic(err)
	}

	res := json.decode(ASCBundleIdCreateResponse, res_raw) or {
		c.error(err.msg)
		panic(err)
	}
	if res.errors.len > 0 {
		c.error(res.errors[0].detail)
	}
	return res
}

fn (c ConnectConfig) fetch_bundle_id(identifier string) ?ASCBundleId {
	res_raw := c.fetch(.get, 'bundleIds?filter[identifier]=${identifier}', '') or {
		c.error('Failed to fetch bundle identifier, $err.msg')
		panic(err)
	}
	res := json.decode(ASCBundleIdResponse, res_raw) or { return err }
	if res.errors.len > 0 {
		return error(res.errors[0].detail)
	}
	if res.data.len <= 0 {
		return none
	}
	return res.data[0]
}