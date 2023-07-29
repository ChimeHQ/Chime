import SwiftUI

@Observable
final class WindowStateSynchronizationModel {
	@ObservationIgnored
	var controlActiveState: ControlActiveState = .inactive {
		didSet {
			print("control state changed")
		}
	}
}
