import SwiftUI

import Theme
import ThemePark
import Utility

@MainActor
@Observable
final class ThemeModel {
	@ObservationIgnored
	let store: ThemeStore

	init(store: ThemeStore) {
		self.store = store
	}

	var themeIdentities: [Theme.Identity] {
		Array(store.all.keys)
	}

	func theme(with identity: Theme.Identity) -> Theme {
		store.theme(with: identity)
	}

	func themeChanged(_ identity: Theme.Identity) {
		store.updateCurrentTheme(with: identity)
	}
}

@MainActor
struct ThemeView: View {
	@State private var model: ThemeModel
	@AppStorage("CurrentTheme", store: UserDefaults.sharedSuite) private var themeId: String = ""

	private let adaptiveColumn = [
		GridItem(.adaptive(minimum: 150))
	]

	init(store: ThemeStore) {
		self._model = State(initialValue: ThemeModel(store: store))
	}

	var body: some View {
		ScrollView {
			LazyVGrid(columns: adaptiveColumn, spacing: 20) {
				ForEach(model.themeIdentities, id: \.self) { identity in
					ThemeTile(theme: model.theme(with: identity), isSelected: identity.storageString == themeId)
						.frame(alignment: .center)
						.onTapGesture {
							updateTheme(identity)
						}
				}
			}
		}
		.padding()
	}

	private func updateTheme(_ identity: Theme.Identity) {
		self.themeId = identity.storageString
		model.themeChanged(identity)

	}
}

#Preview {
	ThemeView(store: ThemeStore())
}
