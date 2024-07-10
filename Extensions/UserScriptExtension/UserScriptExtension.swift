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
