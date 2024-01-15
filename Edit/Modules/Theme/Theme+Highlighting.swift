import Foundation

extension Theme {
	public func syntaxStyle(for name: String, context: Context) -> [NSAttributedString.Key: Any] {
		let color = color(for: .syntaxSpecifier(name), context: context)

		return [.foregroundColor: color]
	}
}
