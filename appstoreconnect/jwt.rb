require "base64"
require "jwt"
ISSUER_ID = ENV["ISSUER_ID"]
KEY_ID = ENV["KEY_ID"]
private_key = OpenSSL::PKey.read(File.read(ENV["KEY_PATH"]))
token = JWT.encode({
        iss: ISSUER_ID,
        exp: Time.now.to_i + 20 * 60,
        aud: "appstoreconnect-v1"
    },
    private_key,
    "ES256",
    header_fields={
        kid: KEY_ID
    }
)
puts token