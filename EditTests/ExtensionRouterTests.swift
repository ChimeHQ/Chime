import XCTest

@testable import ExtensionHost
import ChimeKit

final class ExtensionRouterTests: XCTestCase {
    @MainActor
    func testProjectOpenCloseRouting() async throws {
        let mockA = MockExtension()
        let mockB = MockExtension()
        let router = ExtensionRouter(extensions: [mockA, mockB])

        let expectedContext = ProjectContext(id: ProjectIdentity(), url: URL(filePath: "/path/to/proj"))

        let openExp = expectation(description: "open project")
        let closeExp = expectation(description: "close project")
        openExp.expectedFulfillmentCount = 2
        closeExp.expectedFulfillmentCount = 2

        for mock in [mockA, mockB] {
            mock.didOpenProjectHandler = { context in
                XCTAssertEqual(expectedContext, context)
                openExp.fulfill()
            }

            mock.willCloseProjectHandler = { context in
                XCTAssertEqual(expectedContext, context)
                closeExp.fulfill()
            }
        }

        try router.didOpenProject(with: expectedContext)

		await fulfillment(of: [openExp], timeout: 1.0, enforceOrder: true)

        try router.willCloseProject(with: expectedContext)

        await fulfillment(of: [closeExp], timeout: 1.0)
    }

    @MainActor
    func testOpenCloseDocumentRouting() async throws {
        let mockA = MockExtension()
        let mockB = MockExtension()
        let router = ExtensionRouter(extensions: [mockA, mockB])

        let expectedContext = DocumentContext()

        let openExp = expectation(description: "open doc")
        let closeExp = expectation(description: "close doc")
        openExp.expectedFulfillmentCount = 2
        closeExp.expectedFulfillmentCount = 2

        for mock in [mockA, mockB] {
            mock.didOpenDocumentHandler = { context in
                XCTAssertEqual(expectedContext, context)
                openExp.fulfill()
            }

            mock.willCloseDocumentHandler = { context in
                XCTAssertEqual(expectedContext, context)
                closeExp.fulfill()
            }
        }

        try router.didOpenDocument(with: expectedContext)

        await fulfillment(of: [openExp], timeout: 1.0, enforceOrder: true)

        try router.willCloseDocument(with: expectedContext)

        await fulfillment(of: [closeExp], timeout: 1.0, enforceOrder: true)
    }

    @MainActor
    func testChangeDocumentContextRouting() async throws {
        let mockA = MockExtension()
        let mockB = MockExtension()
        let router = ExtensionRouter(extensions: [mockA, mockB])

        let expectedOldContext = DocumentContext()
        let expectedNewContext = DocumentContext(id: expectedOldContext.id,
                                                 contentId: expectedOldContext.contentId,
                                                 url: expectedOldContext.url,
                                                 uti: .cmakeSource,
                                                 configuration: expectedOldContext.configuration,
                                                 projectContext: nil)

        let changeExp = expectation(description: "change doc")
        changeExp.expectedFulfillmentCount = 2

        for mock in [mockA, mockB] {
            mock.didChangeDocumentContextHandler = { old, new in
                XCTAssertEqual(expectedOldContext, old)
                XCTAssertEqual(expectedNewContext, new)
                changeExp.fulfill()
            }
        }

        try router.didOpenDocument(with: expectedOldContext)
        try router.didChangeDocumentContext(from: expectedOldContext, to: expectedNewContext)

        await fulfillment(of: [changeExp], timeout: 1.0, enforceOrder: true)
    }

    @MainActor
    func testOpenDocumentWhenExtensionsAreUpdated() async throws {
        let mockA = MockExtension()
        let mockB = MockExtension()
        let router = ExtensionRouter(extensions: [mockA])

        let docContext = DocumentContext()

        let _ = try router.didOpenDocument(with: docContext)

        let openExp = expectation(description: "open doc")
        mockB.didOpenDocumentHandler = { context in
            XCTAssertEqual(docContext, context)
            openExp.fulfill()
        }

        for mock in [mockA, mockB] {
            mock.willCloseDocumentHandler = { context in
                XCTFail()
            }
        }

        router.updateExtensions(with: [mockA, mockB])

        await fulfillment(of: [openExp], timeout: 1.0, enforceOrder: true)
    }
}

