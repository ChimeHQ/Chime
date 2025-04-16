import SwiftUI

import UIUtility

struct ItemView: View {
	let item: OpenQuicklyItem

	var title: NSAttributedString {
		let string = NSMutableAttributedString(string: item.title,
											   attributes: [.foregroundColor: secondaryColor])

		for range in item.emphasizedRanges {
			string.setAttributes([.font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)], range: range)
		}
		return string
	}

	private var secondaryColor: NSColor {
		return NSColor.secondaryLabelColor
	}

	var body: some View {
		HStack(alignment: .center, spacing: 0.0) {
			Image(nsImage: item.image)
				.frame(width: 32, height: 32, alignment: .center)
				.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 12.0))
			VStack(alignment: .leading, spacing: 2.0) {
				AttributedText(title)
				Breadcrumb(image: item.location.icon, parts: item.location.parts)
					.foregroundColor(Color(secondaryColor))
			}
		}
		.padding(EdgeInsets(top: 6.0, leading: 12.0, bottom: 6.0, trailing: 12.0))
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

//#Preview {
//    ItemView()
//}
