import Foundation

extension UserDefaults {
	public static var sharedSuite: UserDefaults? {
		UserDefaults(suiteName: CHMUserDefaultsSharedSuite)
	}
}
