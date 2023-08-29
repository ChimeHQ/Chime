import XCTest

@testable import ExtensionHost
import ChimeKit

final class FilteringExtensionTests: XCTestCase {
	private func makeTmpProjectContext() -> ProjectContext {
		let tmpDir = URL(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
		return ProjectContext(url: tmpDir)
	}

	@MainActor
	func testFilteredProject() async throws {
		let mock = MockExtension()

		let configExp = expectation(description: "config")

		mock.configurationHandler = {
			configExp.fulfill()

			// filter everything
			return ExtensionConfiguration(documentFilter: Set(), directoryContentFilter: Set())
		}

		mock.didOpenProjectHandler = { _ in
			XCTFail()
		}

		let deactivateExp = expectation(description: "deactivate")

		let filter = FilteringExtension(ext: mock, deactivate: { deactivateExp.fulfill() })

		let context = makeTmpProjectContext()

		try filter.didOpenProject(with: context)

		await fulfillment(of: [configExp, deactivateExp], enforceOrder: true)
	}

	@MainActor
	func testIncludedProject() async throws {
		let mock = MockExtension()

		mock.configurationHandler = {
			// filter nothing
			return ExtensionConfiguration()
		}

		let openExp = expectation(description: "open project")

		mock.didOpenProjectHandler = { _ in
			openExp.fulfill()
		}

		let filter = FilteringExtension(ext: mock, deactivate: { XCTFail() })

		let context = makeTmpProjectContext()

		try filter.didOpenProject(with: context)

		await fulfillment(of: [openExp], enforceOrder: true)
	}

	@MainActor
	func testOpenUnfilteredDocumentTriggersWholeProject() async throws {
		let mock = MockExtension()

		mock.configurationHandler = {
			return ExtensionConfiguration(documentFilter: [.uti(.rubyScript)],
										  directoryContentFilter: Set())
		}

		mock.didOpenProjectHandler = { _ in XCTFail() }
		mock.didOpenDocumentHandler = { _ in XCTFail() }

		let context = makeTmpProjectContext()

		let filter = FilteringExtension(ext: mock, deactivate: { })

		try filter.didOpenProject(with: context)

		let docAContext = DocumentContext(id: .init(),
										  contentId: .init(),
										  url: nil,
										  uti: .plainText,
										  configuration: .init(),
										  projectContext: context)

		_ = try filter.didOpenDocument(with: docAContext)

		let docBContext = DocumentContext(id: .init(),
										  contentId: .init(),
										  url: nil,
										  uti: .rubyScript,
										  configuration: .init(),
										  projectContext: context)

		let openProjExp = expectation(description: "open project")

		mock.didOpenProjectHandler = { ctx in
			print("project")
			XCTAssertEqual(ctx, context)

			openProjExp.fulfill()
		}

		let openDocAExp = expectation(description: "open doc A")
		let openDocBExp = expectation(description: "open doc B")

		mock.didOpenDocumentHandler = { docCtx in
			if docCtx == docAContext {
				print("doc A")
				openDocAExp.fulfill()
			} else if docCtx == docBContext {
				print(" doc B")
				openDocBExp.fulfill()
			} else {
				XCTFail()
			}
		}

		// this should trigger a project open and two doc opens

		_ = try filter.didOpenDocument(with: docBContext)

		await fulfillment(of: [openProjExp, openDocAExp, openDocBExp], enforceOrder: true)
	}

	@MainActor
	func testClosingLastDocDeactivates() async throws {
		let mock = MockExtension()

		mock.configurationHandler = {
			// filter nothing
			return ExtensionConfiguration()
		}

		let closeDoc = expectation(description: "open project")

		mock.willCloseDocumentHandler = { _ in
			closeDoc.fulfill()
		}

		let deactivateExp = expectation(description: "deactivate")

		let filter = FilteringExtension(ext: mock, deactivate: { deactivateExp.fulfill() })

		let context = DocumentContext()

		_ = try filter.didOpenDocument(with: context)
		try filter.willCloseDocument(with: context)

		await fulfillment(of: [closeDoc, deactivateExp], enforceOrder: true)
	}
}

