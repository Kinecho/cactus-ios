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
### ios bump_build
```
fastlane ios bump_build
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

### ios upload_symbols
```
fastlane ios upload_symbols
```

### ios version_test
```
fastlane ios version_test
```

### ios create_sentry_release
```
fastlane ios create_sentry_release
```

### ios finalize_release
```
fastlane ios finalize_release
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
