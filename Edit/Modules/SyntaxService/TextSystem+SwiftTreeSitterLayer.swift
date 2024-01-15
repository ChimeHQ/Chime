import Foundation

import DocumentContent
import SwiftTreeSitter
import SwiftTreeSitterLayer

extension TextStorage {
	func layerContent(for limit: Int) -> LanguageLayer.Content {
		let fullString = string
		let read = Parser.readFunction(for: fullString, limit: limit)

		return LanguageLayer.Content(
			readHandler: read,
			textProvider: fullString.predicateTextProvider
		)
	}
}

extension TextMetrics {
	func locationTransformer(_ location: Int) -> Point? {
		return nil
//		guard let metrics = valueProvider.sync(.location(location, fill: .optional)) else {
//			return nil
//		}
//
//		guard let line = metrics.line(for: location) else {
//			return nil
//		}
//
//		let column = location - line.location
//		precondition(column >= 0)
//
//		return Point(row: line.index, column: column)
	}
}
