import Foundation
import OSLog

extension Logger {
	/// Initializes a Logger with the main bundle identifier and a type name
	public init<T>(type: T.Type) {
		let subsystem = Bundle.main.bundleIdentifier!
		let category = String(describing: T.self)

		self.init(subsystem: subsystem, category: category)
	}
}
