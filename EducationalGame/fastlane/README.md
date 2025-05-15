fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios swift_lint

```sh
[bundle exec] fastlane ios swift_lint
```

[CI] Check static code quality

### ios test

```sh
[bundle exec] fastlane ios test
```

[CI] Run Unit and UI Tests

### ios build

```sh
[bundle exec] fastlane ios build
```

[CI] Build Artemis Scheme

### ios release

```sh
[bundle exec] fastlane ios release
```

[CI] Upload the newest build to TestFlight

### ios api_key

```sh
[bundle exec] fastlane ios api_key
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
