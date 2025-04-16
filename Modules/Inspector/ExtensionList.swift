import ExtensionFoundation
import SwiftUI

struct ExtensionList: View {
    struct Item: Hashable, Identifiable {
        let identity: AppExtensionIdentity
        let icon: NSImage

        var id: String {
            identity.bundleIdentifier
        }
    }

    @Binding var selection: Item?
    let items: [Item]

    var body: some View {
        List(items, selection: $selection) { item in
            HStack {
                Image(nsImage: item.icon)
                Text(item.identity.localizedName)
            }
        }
    }
}

//#Preview {
//    ExtensionList()
//}
