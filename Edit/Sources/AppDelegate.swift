import AppKit
import OSLog
import SwiftUI

import Document
import ExtensionHost
import PreferencesWindow
import Sparkle
import Theme
import Utility

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	private lazy var updaterController = SPUStandardUpdaterController(updaterDelegate: self, userDriverDelegate: nil)
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
    }

	@IBAction func checkForUpdates(_ sender: Any?) {
//		updaterController.checkForUpdates(sender)
		tryThing()
	}
}

extension AppDelegate: SPUUpdaterDelegate {
	nonisolated func allowedChannels(for updater: SPUUpdater) -> Set<String> {
		["beta"]
	}
}

import SyntaxService
import TreeSitterClient
import Neon
import ThemePark

enum HighlightIntentError: Error {
	case languageConfigurationUnavailable
}

extension AppDelegate {
	func tryThing() {
		Task {
			let source = "let value = \"hello\" "
			let theme = ThemeStore.currentTheme ?? Theme.fallback
			let store = LanguageDataStore.global
			guard let rootConfig = try await store.loadLanguageConfiguration(with: .swiftSource) else {
				throw HighlightIntentError.languageConfigurationUnavailable
			}

			let variant = theme.supportedVariants.first!

			for value in theme.supportedVariants {
				print("variant:", variant)
			}
			let context = Query.Context(controlState: .active, variant: variant)

			let attrProvider: TokenAttributeProvider = { token in
				let style = theme.highlightsQueryCaptureStyle(for: token.name, context: context)

				print(token.name, "=>", style.color)

				return [.foregroundColor: style.color]
			}

			let highlightedSource = try await TreeSitterClient.highlight(
				string: source,
				attributeProvider: attrProvider,
				rootLanguageConfig: rootConfig,
				languageProvider: { store.languageConfiguration(with: $0, background: false) }
			)

			print(highlightedSource)
		}
	}
}
