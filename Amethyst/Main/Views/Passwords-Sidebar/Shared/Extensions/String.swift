
extension String: @retroactive Identifiable {
    public var id: Int { self.hashValue }
}
