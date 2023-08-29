import SwiftUI

struct Breadcrumb: View {
	private static let docImage = NSWorkspace.shared.icon(for: .data)

	let image: NSImage
	let parts: [String]

	private var count: Int {
		return parts.count - 1
	}

	private var text: String {
		return parts.joined(separator: " ‣ ")
	}

	private var lastPart: String? {
		return parts.last
	}

	var body: some View {
		HStack(alignment: .center, spacing: 4.0) {
			Image(nsImage: image)
				.resizable()
				.frame(width: 12, height: 12, alignment: .center)
			Text(text)
				.lineLimit(1)
				.truncationMode(.middle)
				.font(.system(size: 10))
		}
	}
}

#Preview {
//	let docImage = NSWorkspace.shared.icon(for: .data)
	let image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!

	return Group {
		Breadcrumb(image: image, parts: [])
		Breadcrumb(image: image, parts: ["a"])
		Breadcrumb(image: image, parts: ["a", "b"])
		Breadcrumb(image: image, parts: ["a", "b", "c"])
		Breadcrumb(image: image, parts: ["long", "long", "long", "long", "long", "long", "long", "long", "long", "long", "long"])
			.frame(width: 100.0)
	}
}
