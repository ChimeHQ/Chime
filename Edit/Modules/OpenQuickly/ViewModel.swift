import Cocoa
import Combine
import OSLog

import ChimeKit
import FuzzyFind
import Utility

public struct OpenQuicklyContext {
    public typealias SelectionHandler = (OpenQuicklyItem) -> Void

	public let rootURL: URL?
    public let selectionHandler: SelectionHandler

    public init(rootURL: URL?, selectionHandler: @escaping SelectionHandler) {
		self.rootURL = rootURL
        self.selectionHandler = selectionHandler
	}
}

struct OpenQuicklyMatch: Sendable {
	let score: Int
	let ranges: [NSRange]

	static func fromQuery(_ query: String, value: String) -> OpenQuicklyMatch? {
		if let range = value.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) {
			return OpenQuicklyMatch(score: 1000, ranges: [NSRange(range, in: value)])
		}

		guard let fuzzyMatch = bestMatch(query: query, input: value) else {
			return nil
		}

		let ranges = fuzzyMatch.result.highlightedRanges(for: value)
        let nsRanges = ranges.map { NSRange($0, in: value) }

		return OpenQuicklyMatch(score: fuzzyMatch.score.value, ranges: nsRanges)
	}
}

@MainActor
final class OpenQuicklyViewModel: ObservableObject {
	enum SearchState {
		case inactive
		case active
		case complete
	}

	@Published private(set) var items: [OpenQuicklyItem]
	@Published private(set) var searchState: SearchState = .inactive
	var symbolQueryService: SymbolQueryService?

	let context: OpenQuicklyContext
	private let querySubject: PassthroughSubject<String, Never>
	private var subscriptions = Set<AnyCancellable>()
	private var activeSearchTasks: [Task<(), Error>] = []
	private let logger = Logger(type: OpenQuicklyViewModel.self)

	init(context: OpenQuicklyContext, symbolQueryService: SymbolQueryService?) {
		self.items = []
		self.context = context
		self.querySubject = PassthroughSubject()
		self.symbolQueryService = symbolQueryService

		querySubject
			.throttle(for: 1.0, scheduler: DispatchQueue.main, latest: true)
			.sink { query in
				self.runQuery(query)
			}.store(in: &subscriptions)
	}

	func performSearch(with query: String) {
		print("searching: ", query)

		guard query.count > 2 else {
			self.searchState = .inactive
			self.items = []
			return
		}

		querySubject.send(query)
	}

	func activateSelection(with index: Int) {
        let item = items[index]

        context.selectionHandler(item)
	}

	private func runQuery(_ query: String) {
		self.searchState = .active
		self.items = []
		activeSearchTasks.forEach({ $0.cancel() })

		print("running query: ", query)

		let fileTask = Task {
			let time = Date.now
			print("starting file task")
			let rootFilter: (URL) -> Bool = { _ in return true }

			try Task.checkCancellation()

			let urls = context.rootURL.map { recursiveContentsOfDirectory(at: $0, filter: rootFilter) } ?? []

			try Task.checkCancellation()

			let newItems = computeItems(from: urls, query: query)

			print("completed file task: \(Date.now.timeIntervalSince(time))")

			if newItems.isEmpty { return }

			try Task.checkCancellation()

			try await MainActor.run {
				try Task.checkCancellation()

				print("committing file task")

				var allItems = items + newItems

				allItems.sort(by: { $0 > $1 })

				self.items = allItems
			}
		}

		let serviceTask = Task {
			do {
				try await runServiceQuery(query)
			} catch {
				logger.warning("service query failed: \(error, privacy: .public)")
				throw error
			}
		}

		self.activeSearchTasks = [fileTask, serviceTask]
	}

	private func runServiceQuery(_ query: String) async throws {
		guard let service = self.symbolQueryService else { return }

		let time = Date.now
		print("starting service task")

		try Task.checkCancellation()

		let symbols = try await service.symbols(matching: query)

		try Task.checkCancellation()

		let newItems = computeItems(from: symbols, query: query)

		print("completed service task: \(Date.now.timeIntervalSince(time))")

		try Task.checkCancellation()

		if newItems.isEmpty { return }

		try await MainActor.run {
			try Task.checkCancellation()

			print("committing service task")
			var allItems = items + newItems

			allItems.sort(by: { $0 > $1 })

			self.items = allItems
		}
	}
}

extension OpenQuicklyViewModel {
	private func recursiveContentsOfDirectory(at url: URL, filter: (URL) -> Bool) -> [URL] {
		guard let urls = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: []) else {
			return []
		}

		let filteredUrls = urls.filter({ filter($0) && $0.lastPathComponent.hasPrefix(".") == false })

		return filteredUrls + filteredUrls.flatMap({ recursiveContentsOfDirectory(at: $0, filter: { _ in true }) })
	}

	private func computeItems(from urls: [URL], query: String) -> [OpenQuicklyItem] {
		let folderImage = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
		let sharedWorkspace = NSWorkspace.shared
		let rootParts = context.rootURL?.pathComponents ?? []

		return urls.compactMap({ url -> (URL, OpenQuicklyMatch)? in
			let filename = url.lastPathComponent

			guard let match = OpenQuicklyMatch.fromQuery(query, value: filename) else {
				return nil
			}

			return (url, match)
		}).map({ (url, match) in
			let path = url.path
			let filename = url.lastPathComponent

			let components = url.pathComponents.suffix(from: rootParts.count - 1).dropLast()

			let image = sharedWorkspace.icon(forFile: path)
			let score = match.score

			return OpenQuicklyItem(image: image,
						title: filename,
						emphasizedRanges: match.ranges,
						location: .init(icon: folderImage, parts: Array(components), fileURL: url),
						score: score)
		})
	}

	private func computeItems(from symbols: [Symbol], query: String) -> [OpenQuicklyItem] {
		let docImage = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)!

		return symbols.map { symbol -> OpenQuicklyItem in
			let name = symbol.name
			let match = OpenQuicklyMatch.fromQuery(query, value: name)
			let parts = symbol.containerName.map({ [$0] }) ?? []

			return OpenQuicklyItem(image: docImage,
						title: name,
						emphasizedRanges: match?.ranges ?? [],
						location: .init(icon: docImage, parts: parts, fileURL: symbol.url),
						score: match?.score ?? 100)
		}
	}
}

