# V iOS Bundler
A generic utility to bundle and sign iOS binaries.

## Usage

Bundle and sign a binary using `vib <binary path>`. The config file should have the same name as the binary but with `.vib` appended to the filename.

### Example Config

```
bundle_name=HelloWorld
bundle_id=app.vlang.helloworld
bundle_version=1
display_name=Hello World
team_id=APPLETEAMID
codesign_identity=Apple Development: Leah Lundqvist (IDENTITY_ID)
provisioning_profile=app_vlang_helloworld.mobileprovision
```

### Provisioning Profile Wizard

To enable automated provisioning, you need to create an API key on [App Store Connect](https://appstoreconnect.apple.com/access/api). Save the key file to `~/.vib` and create a file called `config.vib` in the same directory containing
```
issuer_id=<App Store Connect Issuer ID>
key_id=<Key ID>
key_file=AuthKey_<Key ID>.p8
```

Use `vib provision` to enter the provisioning profile wizard. For now you need to already have codesigning a certificate on your machine. Generating and installing a new one will be automated by Vib in the future as well.