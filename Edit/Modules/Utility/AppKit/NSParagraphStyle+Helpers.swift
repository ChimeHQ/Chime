import AppKit

extension NSParagraphStyle {
	public static let rightAligned = NSParagraphStyle.with(block: { $0.alignment = .right })
	public static let centered = NSParagraphStyle.with(block: { $0.alignment = .center })

	public static func with(block: (NSMutableParagraphStyle) -> Void) -> NSParagraphStyle {
		let paragraphStyle = NSMutableParagraphStyle()

		block(paragraphStyle)

		return paragraphStyle
	}
}
