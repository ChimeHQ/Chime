# Structure

Understand how Chime's Xcode project is structured.

## Overview

The Chime project makes extensive use of xcconfig files and static libraries for modularization.

### xcconfig

Build settings should be set within xcconfig files, and all targets should have an xconfig set for all build configurations. This can be verified with [XCLint](https://github.com/mattmassicotte/XCLint).

### Modules

The application's code is organized into pretty fine-grained modules via static libraries. These should all use the `Module` xcconfig.

However, due to an Xcode bug, static libraries that depend on SPM modules with non-Swift code will fail to build. To workaround this, those modules need to use the `WorkaroundModule` config file. This bug is transitive, so if module A depends on B, and B uses one of these problematic packages, **both** A and B need to use `WorkaroundModule`. I realize this is annoying and I would very much like to find a more reasonable solution.

### EditKit

Most internal modules are linked into a dynamic framework container called `EditKit`. This is used by the main Edit executable, along with the Quick Look preview and AppIntent extension.
