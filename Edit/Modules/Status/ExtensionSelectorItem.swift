import SwiftUI

import Theme

public struct ExtensionSelectorItem: View {
    @Environment(\.theme) private var theme
    @Environment(\.controlActiveState) private var controlActiveState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.statusBarPadding) private var padding

    public init() {
    }
    
    private var context: Theme.Context {
        .init(controlActiveState: controlActiveState, hover: false, colorScheme: colorScheme)
    }
    
    public var body: some View {
        StatusItem {
            Image(systemName: "puzzlepiece.extension")
                .font(Font(theme.font(for: .statusLabel, context: context)))
        }
        .padding(padding)
    }
}

#Preview {
    ExtensionSelectorItem()
}
