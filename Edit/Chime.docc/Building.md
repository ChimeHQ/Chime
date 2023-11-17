# Building

Get started with local development.

## Overview

Chime is built using Xcode. The project is not entirely self-contained, however. The idea is to keep things as simple as possible, but there are a few steps you need to take to get set up for local development. 

### Prepare the local copy

After forking, clone your fork locally. From there you need to do two things. You must also check out all submodules.

```sh
git submodule update --init --recursive
```

Chime imports bundled extension projects using submodules to workaround an SPM limitation. All extensions need to link in ChimeKit. The Chime application builds a single, shared copy of ChimeKit as a dynamic framework. There is, it seems, no way to have an SPM module **build** against a dependency without also **linking** against it. This would result in too much duplication within Chime's internal application bundle. So we have to play this dance.

### Configure signing

All macOS apps must be code-signed. You'll need a developer account with a team id to do this. Once you have one, you can configure it in the `User.xcconfig` file. This is just for your local work, it is not checked into version control.

```sh
cp User.xcconfig.template User.xcconfig
```

There are two values to configure here. Your team id must be set for `DEVELOPMENT_TEAM`. Optionally, you can also control the `BUNDLE_ID_PREFIX` used for all of the Chime artifacts that require a bundle id.
