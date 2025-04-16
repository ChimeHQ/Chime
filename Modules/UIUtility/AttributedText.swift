import SwiftUI
import NSUI

@MainActor
public struct AttributedText: NSUIViewRepresentable {
	public typealias NSUIViewType = NSUILabel

	private let text: NSAttributedString

	public init(_ attributedString: NSAttributedString) {
		text = attributedString
	}

	public func makeNSUIView(context: Self.Context) -> NSUIViewType {
#if os(macOS)
		let textField = NSUIViewType(labelWithAttributedString: text)

		textField.isSelectable = true
#else
		let textField = NSUIViewType()

		textField.attributedText = text
#endif
//        textField.allowsEditingTextAttributes = true // Fix of clear of styles on click

		textField.preferredMaxLayoutWidth = textField.frame.width

		return textField
	}

	public func updateNSUIView(_ view: NSUIViewType, context: Self.Context) {
		view.attributedText = text
	}
}

#Preview {
    AttributedText(NSAttributedString(string: "hello"))
}
