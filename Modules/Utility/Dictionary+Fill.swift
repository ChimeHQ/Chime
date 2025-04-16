extension Dictionary {
	/// Get the key, or create and add it using a closure.
	public mutating func getOrFill(
		key: Key,
		_ create: () -> Value
	) -> Value {
		if let value = self[key] {
			return value
		}

		let value = create()

		self[key] = value

		return value
	}
}
