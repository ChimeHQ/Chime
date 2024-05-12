import Foundation

import ThemePark

struct CodableTheme: Codable {
	let styler: CodableStyler
	let identity: Theme.Identity
}
