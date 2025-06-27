import Combine
import ComposableArchitecture
import Foundation
import Network

@DependencyClient
struct NetworkMonitorClient {
    var isOnline: @Sendable () -> Bool = { true }
    public var delegate: @Sendable () async -> AsyncStream<Action> = { .never }
    public var statusStream: @Sendable () async throws -> AsyncStream<Bool>

    enum Action: Equatable {
        case online
        case offline
    }
}

extension NetworkMonitorClient {
    static var live: Self {
        let task = Task<NetworkMonitorClient.Delegate, Never> { @MainActor in
            return NetworkMonitorClient.Delegate()
        }

        return Self(
            isOnline: { true },
            delegate: { @MainActor in
                let delegate = await task.value
                return AsyncStream { delegate.registerContinuation($0) }
            },
            statusStream: {
                AsyncStream { continuation in
                    let monitor = NWPathMonitor()
                    monitor.pathUpdateHandler = { path in
                        continuation.yield(path.status == .satisfied)
                    }
                    monitor.start(queue: .global())

                    continuation.onTermination = { _ in
                        monitor.cancel()
                    }
                }
            }
        )
    }

    public final class Delegate: @unchecked Sendable {
        let continuations: LockIsolated<[UUID: AsyncStream<NetworkMonitorClient.Action>.Continuation]>
        private var queue = DispatchQueue(label: "NetworkMonitorClient")
        private var monitor = NWPathMonitor()

        init() {
            self.continuations = .init([:])
            monitor.pathUpdateHandler = { path in
                Task { @MainActor in
                    let isConnected = path.status == .satisfied
                    var connectionType: NWInterface.InterfaceType?

                    let types: [NWInterface.InterfaceType] = [.wifi, .cellular, .wiredEthernet, .loopback]
                    if let type = types.first(where: { path.usesInterfaceType($0) }) {
                        connectionType = type
                    } else {
                        connectionType = nil
                    }

                    if let connectionType {
                        self.send(.online)
                    } else {
                        self.send(.offline)
                    }
                }
            }
            startMonitoring()
        }

        private func startMonitoring() {
            monitor.start(queue: queue)
        }

        func stopMonitoring() {
            monitor.cancel()
        }

        func registerContinuation(_ continuation: AsyncStream<NetworkMonitorClient.Action>.Continuation) {
            Task { [continuations] in
                continuations.withValue {
                    let id = UUID()
                    $0[id] = continuation
                    continuation.onTermination = { [weak self] _ in self?.unregisterContinuation(withID: id) }
                }
            }
        }

        private func unregisterContinuation(withID id: UUID) {
            Task { [continuations] in continuations.withValue { $0.removeValue(forKey: id) } }
        }

        public func send(_ action: NetworkMonitorClient.Action) {
            Task { [continuations] in
                continuations.withValue { $0.values.forEach { $0.yield(action) } }
            }
        }
    }
}

extension DependencyValues {
    var networkMonitorClient: NetworkMonitorClient {
        get { self[NetworkMonitorClient.self] }
        set { self[NetworkMonitorClient.self] = newValue }
    }
}

extension NetworkMonitorClient: DependencyKey {
    public static let testValue = Self()
    public static let liveValue = Self.live
}
