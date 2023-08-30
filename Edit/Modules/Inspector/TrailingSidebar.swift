import SwiftUI

// this is a super-gross hack
@MainActor
fileprivate let dividerColor = {
    let splitView = NSSplitView()

    splitView.dividerStyle = .thin

    return splitView.dividerColor
}()

struct TrailingSidebarView<Content: View>: View {
    @Environment(\.windowState) private var windowState

    let content: Content

    init(content: () -> Content) {
        self.content = content()
    }

    private var ignoringTopSafeArea: Bool {
        windowState.tabBarVisible == false
    }

    private var edges: Edge.Set {
        ignoringTopSafeArea ? [] : [.all]
    }
    
    private var topSeperator: some View {
        return Divider().opacity(ignoringTopSafeArea ? 0.0 : 1.0)
    }

    private var leadingDivider: some View {
        return Rectangle()
            .frame(width: 1, height: nil)
            .foregroundColor(Color(dividerColor))
            .ignoresSafeArea(.container, edges: edges)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(leadingDivider, alignment: .leading)
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: edges)
            .overlay(topSeperator, alignment: .top)
    }
}
