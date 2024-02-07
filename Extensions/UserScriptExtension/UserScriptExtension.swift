import Foundation
import os.log

import ChimeKit

@MainActor
public final class UserScriptExtension {
	let host: any HostProtocol
	private let lspService: LSPService

	public init(host: any HostProtocol) {
		self.host = host

//		let logger = Logger(subsystem: "com.chimehq.Edit", category: "UserScriptExtension")
//
//		let url = try! FileManager.default.url(
//			for: .applicationScriptsDirectory,
//			in: .userDomainMask,
//			appropriateFor: nil,
//			create: false
//		)
//			.appendingPathComponent("com.chimehq.LanguageServerScripts/gopls.sh")
//
//		logger.warning("trying: \(url.path)")
//
//		let task = try! NSUserUnixTask(url: url)
//
//		let stdoutPipe = Pipe()
//
//		task.standardOutput = stdoutPipe.fileHandleForWriting
//
//		task.execute(withArguments: ["version"]) { error in
//			print("error: \(error)")
//
//			let data = try! stdoutPipe.fileHandleForReading.readToEnd() ?? Data()
//			let output = String(decoding: data, as: UTF8.self)
//
//			logger.warning("read: \(output, privacy: .public)")
//		}

		self.lspService = LSPService(
			host: host,
			serverOptions: Gopls.serverOptions,
			execution: .unixScript(
				path: "com.chimehq.LanguageServerScripts/gopls.sh",
				arguments: ["run"]
			)
		)
	}
}
extension UserScriptExtension: ExtensionProtocol {
	public var configuration: ExtensionConfiguration {
		ExtensionConfiguration(
			contentFilter: [.uti(.goSource), .uti(.goModFile), .uti(.goWorkFile)],
			serviceConfiguration: ServiceConfiguration(completionTriggers: ["."])
		)
	}

	public var applicationService: some ApplicationService {
		return lspService
	}
}

struct Gopls {
}

extension Gopls {
	struct ServerOptions: Codable {
		enum HoverKind: String, Codable {
			case FullDocumentation
			case NoDocumentation
			case SingleLine
			case Structured
			case SynopsisDocumentation
		}

		let usePlaceholders: Bool
		let completeUnimported: Bool
		let deepCompletion: Bool
		let hoverKind: HoverKind
		let semanticTokens: Bool
		let staticcheck: Bool
		let gofumpt: Bool
	}

	static var serverOptions: some Codable {
		let stackcheckEnabled = true
		let gofumptEnabled = true

		return ServerOptions(usePlaceholders: true,
							 completeUnimported: true,
							 deepCompletion: true,
							 hoverKind: .Structured,
							 semanticTokens: true,
							 staticcheck: stackcheckEnabled,
							 gofumpt: gofumptEnabled)
	}
}
