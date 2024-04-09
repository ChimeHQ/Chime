import XCTest

@testable import DocumentContent

extension TextStorage where Version == Int {
	public init(textStorage: NSTextStorage) {
		self.init(
			beginEditing: { textStorage.beginEditing() },
			endEditing: { textStorage.endEditing() },
			applyMutations: { mutations in
				for mutation in mutations {
					for rangedString in mutation.stringMutations {
						textStorage.replaceCharacters(in: rangedString.range, with: rangedString.string)
					}
				}
			},
			version: { textStorage.hashValue },
			length: { version in
				guard version == textStorage.hashValue else { return nil }

				return textStorage.length
			},
			substring: { range, version in
				guard version == textStorage.hashValue else { throw TextStorageError.stale }

				return textStorage.attributedSubstring(from: range).string
			}
		)
	}
}

final class TextMetricsTests: XCTestCase {
	@MainActor
	func makeMetrics(with string: String) -> (TextMetrics, TextStorage<Int>) {
		let textStorage = NSTextStorage(string: string)
		let storage = TextStorage<Int>(textStorage: textStorage)
		let metrics = TextMetrics(storage: storage)

		return (metrics, storage)
	}

	@MainActor
	func testLineCountAfterInitialization() {
		let (metrics, _) = makeMetrics(with: "")

		XCTAssertEqual(1, metrics.lineCount)
	}
}
