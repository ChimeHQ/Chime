import AppKit
import OSLog
import SwiftUI

import Document
import ExtensionHost
import PreferencesWindow
import Theme

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let documentController: ProjectDocumentController
	private lazy var preferencesController: NSWindowController = {
		let window = NSWindow(contentRect: .zero, styleMask: [.closable, .titled], backing: .buffered, defer: true)

		window.contentView = NSHostingView(rootView: SettingsView(themeStore: themeStore))

		return NSWindowController(window: window)
	}()

	private let extensionSystem: ExtensionSystem
	private let themeStore = ThemeStore()

	private var tempWindow: NSWindow?

    override init() {
        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
        ])

        // NSDocumentController subclass instances must be manually created before any NSDocumentController functionality is used
		self.documentController = ProjectDocumentController(themeStore: themeStore)
		self.extensionSystem = ExtensionSystem(documentController: documentController)

		super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
	@IBAction func showPreferences(_ sender: Any?) {
		preferencesController.window?.center()
		preferencesController.showWindow(self)

//		let controller = PreviewViewController(nibName: nil, bundle: nil)
//
//		let window = NSWindow(contentViewController: controller)
//
//		window.setContentSize(.init(width: 600, height: 600))
//		window.makeKeyAndOrderFront(nil)
//
//		Task {
//			let url = URL(fileURLWithPath: "/Users/matt/Desktop/RunloopActor.swift")
//			try! await controller.preparePreviewOfFile(at: url)
//		}
//
//		self.tempWindow = window
    }
}

//import ChimeKit
//import Editor
//import Theme
//import UIUtility
//import UniformTypeIdentifiers
//
//extension URL {
//	var contentType: UTType? {
//		get throws {
//			try resourceValues(forKeys: [.contentTypeKey]).contentType
//		}
//	}
//
//	var resolvedContentType: UTType? {
//		get throws {
//			guard let utType = try contentType else { return nil }
//
//			return UTType.resolveType(with: utType.identifier, url: self)
//		}
//	}
//}
//
//final class PreviewViewController: NSViewController {
//	private let coordinator: DocumentCoordinator<TokenServicePlaceholder>
//
//	private let theme: Theme
//
//	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
//		self.coordinator = DocumentCoordinator()
//
//		let themeId = UserDefaults.standard.string(forKey: "theme-identifier") ?? "Midnight.xcode"
//		self.theme = ThemeStore().theme(with: themeId)
//
//		super.init(nibName: nil, bundle: nil)
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	override func loadView() {
//		let hostingView = RepresentableViewController({ self.coordinator.editorContentController })
//			.environment(\.theme, theme)
//
//		self.view = NSHostingView(rootView: hostingView)
//
//		coordinator.highlighter.updateTheme(theme, context: .init(window: nil))
//	}
//
//	func preparePreviewOfFile(at url: URL) async throws {
//		let config = DocumentConfiguration()
//		let context = Query.Context(window: self.view.window)
//		let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)
//
//		try coordinator.textSystem.reload(from: url, attributes: attrs)
//
//		let newContentId = coordinator.textSystem.contentIdentity
//
//		let utType = (try? url.resolvedContentType) ?? UTType.plainText
//
//		let initial = DocumentContext()
//		let new = DocumentContext(
//			id: initial.id,
//			contentId: newContentId,
//			url: url,
//			uti: utType,
//			configuration: initial.configuration,
//			projectContext: nil
//		)
//
//		coordinator.documentContextChanged(from: initial, to: new)
//	}
//}
