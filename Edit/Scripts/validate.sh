#!/bin/sh

set -euxo pipefail

# checks for all configurations
if [ ! -d "$BUILT_PRODUCTS_DIR/Chime.app/Contents/Frameworks/ChimeKit.framework" ]; then
    echo "error: ChimeKit.framework not embedded"
    exit 1
fi

if [ "$CONFIGURATION" == "Debug" ] ; then
    exit 0
fi

# checks for just production builds

if [ -d "$BUILT_PRODUCTS_DIR/Chime.app/Contents/Extensions/UIPlaceholderExtension.appex" ]; then
    echo "error: UIPlaceholderExtension still embedded"
    exit 1
fi
