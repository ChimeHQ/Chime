import SwiftUI

@MainActor
fileprivate let dividerColor = {
    let splitView = NSSplitView()

    splitView.dividerStyle = .thin

    return splitView.dividerColor
}()

struct TrailingSidebarView<Content: View>: View {
    let ignoringTopSafeArea: Bool
    let content: Content

    init(ignoringTopSafeArea: Bool = false, content: () -> Content) {
        self.ignoringTopSafeArea = ignoringTopSafeArea
        self.content = content()
    }

    private var edges: Edge.Set {
        return ignoringTopSafeArea ? .top : Edge.Set()
    }

    private var topSeperator: some View {
        return Divider().opacity(ignoringTopSafeArea ? 0.0 : 1.0)
    }

    private var leadingDivider: some View {
        return Rectangle()
            .frame(width: 1, height: nil).foregroundColor(Color(dividerColor))
            .edgesIgnoringSafeArea(edges)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(leadingDivider, alignment: .leading)
            .background(.ultraThickMaterial, ignoresSafeAreaEdges: edges)
            .overlay(topSeperator, alignment: .top)
    }
}
