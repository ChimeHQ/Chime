import SwiftUI

import Theme
import ThemePark

public struct ExtensionSelectorItem: View {
    @Environment(\.theme) private var theme
    @Environment(\.statusBarPadding) private var padding

    public init() {
    }
    
    public var body: some View {
        StatusItem {
            Image(systemName: "puzzlepiece.extension")
				.themeFont(.editor(.accessoryForeground))
        }
        .padding(padding)
    }
}

#Preview {
    ExtensionSelectorItem()
}
