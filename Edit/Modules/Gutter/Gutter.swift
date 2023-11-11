import SwiftUI

public struct Gutter: View {
	public init() {
	}
	
    public var body: some View {
		Color.yellow.ignoresSafeArea()
    }
}

#Preview {
    Gutter()
}
