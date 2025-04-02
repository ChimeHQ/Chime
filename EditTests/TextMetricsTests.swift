import AppKit
import Testing

@testable import DocumentContent

extension TextStorage where Version == Int {
	public init(textStorage: NSTextStorage) {
		self.init(
			beginEditing: { textStorage.beginEditing() },
			endEditing: { textStorage.endEditing() },
			applyMutation: { mutation in
				textStorage.replaceCharacters(in: mutation.range, with: mutation.string)
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

struct TextMetricsTests {
	@MainActor
	func makeMetrics(with string: String) -> (TextMetricsCalculator, TextStorage<Int>) {
		let textStorage = NSTextStorage(string: string)
		let storage = TextStorage<Int>(textStorage: textStorage)
		let metrics = TextMetricsCalculator(storage: storage)

		return (metrics, storage)
	}

	@MainActor
	@Test func testAsyncLineCountAfterInitialization() async {
		let (calculator, _) = makeMetrics(with: " ")

		let metrics = await calculator.valueProvider.async(.entireDocument(fill: .required))
		
		#expect(metrics.lineCount == 1)
	}
	
	@MainActor
	@Test func testSyncLineCountAfterInitialization() {
		let (calculator, _) = makeMetrics(with: " ")

		withKnownIssue("The line processor currently does not support a fully synchronous path") {
			let metrics = calculator.valueProvider.sync(.entireDocument(fill: .required))
		
			#expect(metrics?.lineCount == 1)
		}
	}
}
