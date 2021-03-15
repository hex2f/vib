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