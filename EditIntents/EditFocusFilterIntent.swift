import AppIntents

import Theme

struct ThemeEntityQuery: EntityQuery {
	func entities(for identifiers: [ThemeEntity.ID]) async -> [ThemeEntity] {
//		await ThemeStore.availableIdentities
		await suggestedEntities()
//			.filter { identifiers.contains($0.storageString) }
//			.map { ThemeEntity(themeIdentity: $0) }
	}


	func suggestedEntities() async -> [ThemeEntity] {
//		await ThemeStore.availableIdentities
//			.map { ThemeEntity(themeIdentity: $0) }
		[
			ThemeEntity(themeIdentity: .init(source: .xcode, name: "Bare")),
			ThemeEntity(themeIdentity: .init(source: .bbedit, name: "Another")),
		]
	}
}

struct ThemeEntity: AppEntity {
	static var typeDisplayRepresentation: TypeDisplayRepresentation {
		TypeDisplayRepresentation(name: "Theme")
	}

	static let defaultQuery = ThemeEntityQuery()

	let themeIdentity: Theme.Identity

	var id: String {
		themeIdentity.storageString
	}

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(
			title: "\(themeIdentity.name)",
			subtitle: "\(themeIdentity.source.name) Theme"
		)
	}
}

//struct ThemeDynamicOptionsProvider: DynamicOptionsProvider {
//	func results() async throws -> IntentItemCollection<ThemeEntity> {
//		let identities = await ThemeStore.availableIdentities
//		let xcodeThemes = identities
//			.filter({ $0.source == .xcode })
//			.map { ThemeEntity(themeIdentity: $0) }
//
//		return IntentItemCollection(
//			sections: [
//				IntentItemSection("Xcode", items: xcodeThemes)
//			]
//		)
//	}
//}

struct EditFocusFilterIntent: SetFocusFilterIntent {
	static let title = LocalizedStringResource(stringLiteral: "Set Theme")
	static let description: LocalizedStringResource? = "Change active editor theme"

	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(stringLiteral: "Set Theme to something")
	}

	@Parameter(title: "Selected Theme")
	var theme: ThemeEntity

	func perform() async throws -> some IntentResult {
		UserDefaults.sharedSuite?.setValue("CurrentTheme", forKey: theme.themeIdentity.storageString)
		return .result()
	}
}
