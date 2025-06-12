import Dependencies

public extension DependencyValues {
    var customClient: CustomClient {
        get { self[CustomClient.self] }
        set { self[CustomClient.self] = newValue }
    }
}

extension CustomClient: DependencyKey {
    public static let testValue = Self()
    public static let liveValue = Self.live
}
