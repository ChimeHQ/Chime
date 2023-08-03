@preconcurrency import ExtensionFoundation
import Foundation
import OSLog

import ChimeKit
import Semaphore
import Utility

enum RunningRemoteExtensionError: Error {
	case selfUnavailable
}

@available(macOS 13.0, *)
@MainActor
public final class RunningRemoteExtension {
	@MainActor
	private struct RunningExtension {
		let process: AppExtensionProcess
		let connection: NSXPCConnection
	}

	private let logger = Logger(type: RunningRemoteExtension.self)
	private var runningExtension: RunningExtension?
	private let semaphore = AsyncSemaphore(value: 1)
	private(set) lazy var remoteExtension: RemoteExtension = {
		RemoteExtension(connectionProvider: { [weak self] in
			guard let self = self else { throw RunningRemoteExtensionError.selfUnavailable }

			return try await self.getConnection()
		})
	}()

	let identity: AppExtensionIdentity
	let host: any HostProtocol

	public init(identity: AppExtensionIdentity, host: HostProtocol) async throws {
		self.identity = identity
		self.host = host
	}

	nonisolated var identifier: String {
		return identity.bundleIdentifier
	}

	/// Deactivate the underlying `AppExtensionProcess` if it is currently active.
	func deactivate() {
		logger.info("deactivating: \(self.identifier, privacy: .public)")

		runningExtension?.process.invalidate()
		runningExtension = nil
	}
}

@available(macOS 13.0, *)
extension RunningRemoteExtension {
	private func getConnection() async throws -> NSXPCConnection {
		await semaphore.wait()
		defer { semaphore.signal() }

		if let runningExtension = runningExtension {
			return runningExtension.connection
		}

		let runningExt = try await startExtension(with: identity)

		self.runningExtension = runningExt

		return runningExt.connection
	}

	private func startExtension(with identity: AppExtensionIdentity) async throws -> RunningExtension {
		logger.info("activating: \(self.identifier, privacy: .public)")

		// these warnings cannot be resolved without Apple changing something about the API
		let config = AppExtensionProcess.Configuration(appExtensionIdentity: identity, onInterruption: { [weak self] in
			self?.nonisoHandleProcessInterruption()
		})

		let process = try await AppExtensionProcess(configuration: config)

		let connection = try process.makeXPCConnection()

		connection.interruptionHandler = { [weak connection] in
			connection?.invalidate()
		}

		connection.invalidationHandler = { [weak self] in
			self?.nonisoHandleConnectionInvalidation()
		}

		host.export(over: connection, remoteExtension: remoteExtension)

		connection.activate()

		return RunningExtension(process: process, connection: connection)
	}

	private nonisolated func nonisoHandleProcessInterruption() {
		Task { await self.handleProcessInterruption() }
	}

	private nonisolated func nonisoHandleConnectionInvalidation() {
		Task { await self.handleConnectionInvalidation() }
	}

	private func handleProcessInterruption() {
		logger.info("process interrupted: \(self.identifier, privacy: .public)")

		deactivate()
	}

	private func handleConnectionInvalidation() {
		logger.info("connection invalidated: \(self.identifier, privacy: .public)")

		deactivate()
	}
}

@available(macOS 13.0, *)
@MainActor
final class LazyRemoteExtension {
	private let runningExtension: RunningRemoteExtension

	let configuration: ExtensionConfiguration

	init(identity: AppExtensionIdentity, host: HostProtocol) async throws {
		self.runningExtension = try await RunningRemoteExtension(identity: identity, host: host)
		self.configuration = try await runningExtension.remoteExtension.configuration
	}

	func deactivate() {
		runningExtension.deactivate()
	}
}

@available(macOS 13.0, *)
extension LazyRemoteExtension: ExtensionProtocol {
	var applicationService: ApplicationService {
		get throws { runningExtension.remoteExtension }
	}
}

