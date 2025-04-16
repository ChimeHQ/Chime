import SwiftUI

import Status
import WindowTreatment

@MainActor
public struct Inspector: View {
    @State private var selectorVisible = false
    @State private var model = InspectorModel()

	public init() {
	}

	public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TrailingSidebarView() {
                ExtensionContent()
            }
            ExtensionSelectorItem()
                .onTapGesture { selectorVisible = true }
                .popover(isPresented: $selectorVisible, arrowEdge: .top, content: {
                    ExtensionList(selection: $model.selection, items: model.items)
                })
        }
	}
}
