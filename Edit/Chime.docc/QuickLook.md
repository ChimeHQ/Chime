# QuickLook Preview Extension

Work with the extension that integrates with the macOS QuickLook system.

## Overview

...

### Debugging

More than one local copy of Chime can throw off extension resolution. You can check for this using `pluginkit`:

`pluginkit -mD -p com.apple.quicklook.preview`

### UTIs

The UTIs given to `QLSupportedContentTypes` must be explict. Conforming to a supported parent type is not enough.
