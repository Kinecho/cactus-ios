fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios bump
```
fastlane ios bump
```

### ios print_version
```
fastlane ios print_version
```

### ios patch
```
fastlane ios patch
```

### ios minor
```
fastlane ios minor
```

### ios version_bump
```
fastlane ios version_bump
```

### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios manual_upload
```
fastlane ios manual_upload
```

### ios add_devices
```
fastlane ios add_devices
```

### ios test
```
fastlane ios test
```

### ios lint
```
fastlane ios lint
```

### ios certificates
```
fastlane ios certificates
```

### ios create_release
```
fastlane ios create_release
```

### ios finalize_release
```
fastlane ios finalize_release
```

### ios upload_symbols
```
fastlane ios upload_symbols
```

### ios upload_symbols_stage
```
fastlane ios upload_symbols_stage
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
