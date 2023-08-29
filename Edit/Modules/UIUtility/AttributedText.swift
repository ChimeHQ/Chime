import SwiftUI

public struct AttributedText: NSViewRepresentable {
	public typealias NSViewType = NSTextField

	private let text: NSAttributedString

	public init(_ attributedString: NSAttributedString) {
		text = attributedString
	}

	public func makeNSView(context: Self.Context) -> NSTextField {
		let textField = NSTextField(labelWithAttributedString: text)
		textField.isSelectable = true
//        textField.allowsEditingTextAttributes = true // Fix of clear of styles on click

		textField.preferredMaxLayoutWidth = textField.frame.width

		return textField
	}

	public func updateNSView(_ nsView: NSTextField, context: Self.Context) {
		nsView.attributedStringValue = text
	}
}

#Preview {
    AttributedText(NSAttributedString(string: "hello"))
}
