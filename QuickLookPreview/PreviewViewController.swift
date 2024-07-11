import Cocoa
import SwiftUI
import Quartz

import ChimeKit
import Editor
import Theme
import UIUtility

final class PreviewViewController: NSViewController, QLPreviewingController {
	private let coordinator: DocumentCoordinator<TokenServicePlaceholder>

	private let theme: Theme

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		self.coordinator = DocumentCoordinator(statusBarVisible: false)

		self.theme = ThemeStore.currentTheme ?? Theme.fallback

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		let hostingView = RepresentableViewController({ self.coordinator.editorContentController })
			.environment(\.theme, theme)

		self.view = NSHostingView(rootView: hostingView)

		let effectiveAppearance = view.effectiveAppearance

		if theme.supportedVariants.contains(.init(appearance: effectiveAppearance)) == false {
			view.appearance = theme.supportedVariants.first?.appearance
		}

		coordinator.highlighter.updateTheme(theme, context: .init(window: nil))
    }

	func preparePreviewOfFile(at url: URL) async throws {
		let config = DocumentConfiguration()
		let context = Query.Context(window: self.view.window)
		let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)

		try coordinator.textSystem.reload(from: url, attributes: attrs)

		let newContentId = coordinator.textSystem.contentIdentity

		let utType = (try? url.resolvedContentType) ?? UTType.plainText

		let initial = DocumentContext()
		let new = DocumentContext(
			id: initial.id,
			contentId: newContentId,
			url: url,
			uti: utType,
			configuration: initial.configuration,
			projectContext: nil
		)

		coordinator.documentContextChanged(from: initial, to: new)
	}
}
