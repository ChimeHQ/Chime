import Foundation

import RangeState

public final class LayoutInvalidationBuffer {
	enum State {
		case idle
		case buffering
		case invalidated
	}

	private var state = State.idle
	public var handler: () -> Void = { }

	public init() {
	}

	public func willLayout() {
		state = .buffering
	}

	public func didLayout() {
		switch state {
		case .idle:
			fatalError()
		case .buffering:
			break
		case .invalidated:
			handler()
		}

		self.state = .idle
	}

	public func contentVisibleRectChanged() {
		switch state {
		case .idle:
			handler()
		case .buffering, .invalidated:
			self.state = .invalidated
		}
	}
}
