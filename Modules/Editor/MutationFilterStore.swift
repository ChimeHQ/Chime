import UniformTypeIdentifiers

import TextFormation

final class MutationFilterStore<Interface: TextFormation.TextSystemInterface> {
	func filter(for utType: UTType) -> (any Filter<Interface>)? {
		if utType.conforms(to: .markdown) {
			return Self.genericFilter()
		}
		
		if utType.conforms(to: .swiftSource) {
			return Self.genericFilter()
		}
		
		return Self.genericFilter()
	}
}

extension MutationFilterStore {
	private static func genericFilter() -> any Filter<Interface> {
		let filters: [any Filter<Interface>] = LanguageFilters.generic()

		return CompositeFilter(filters: filters)
	}
}
