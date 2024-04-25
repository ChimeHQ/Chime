import SwiftUI

// adapted from https://gist.github.com/groue/28369e1d99319c90dea5fb8cd305cb39

/// A property wrapper type that instantiates an observable object.
///
/// It's like `@State`, except that just like `@StateObject` its
/// initializer accepts an autoclosure so that a single instance of the
/// observable object is created for the whole lifetime of the view.
///
/// For example:
///
/// ```swift
/// @Observable MyModel {
///     init() { ... }
/// }
///
/// struct MyView: View {
///     @ObservableState var myModel = MyModel()
///
///     var body: some View { ... }
/// }
/// ```
@MainActor
@propertyWrapper
public struct ObservableState<Value: AnyObject & Observable>: DynamicProperty {
	@StateObject private var container = ValueContainer<Value>()
	let makeValue: () -> Value

	public init(wrappedValue: @autoclosure @escaping () -> Value) {
		self.makeValue = wrappedValue
	}

	public var wrappedValue: Value {
		container.value ?? makeValue()
	}

	public var projectedValue: Wrapper {
		Wrapper(value: wrappedValue)
	}

	public nonisolated func update() {
		Task { @MainActor in
			if container.value == nil {
				container.value = makeValue()
			}
		}
	}

	@dynamicMemberLookup
	public struct Wrapper {
		let value: Value

		subscript<Subject>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>
		) -> Binding<Subject> {
			Binding(
				get: { value[keyPath: keyPath] },
				set: { value[keyPath: keyPath] = $0 })
		}

	}
}

/// The object that is instantiated once with `@StateObject` and takes care
/// of the lifetime of the value.
private final class ValueContainer<Value: Observable>: ObservableObject {
	// No need to make it @Published because Value is Observable.
	var value: Value?
}
