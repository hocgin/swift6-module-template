import Combine
import ComposableArchitecture
import Foundation
import Network

@DependencyClient
struct NetworkMonitorClient {
    public var delegate: @Sendable () async -> AsyncStream<Action> = { .never }

    enum Action: Equatable {
        case online(NWInterface.InterfaceType?)
        case offline(NWInterface.InterfaceType?)
    }
}

extension NetworkMonitorClient {
    static var live: Self {
        let task = Task<NetworkMonitorClient.Delegate, Never> { @MainActor in
            return NetworkMonitorClient.Delegate()
        }

        return Self(
            delegate: { @MainActor in
                let delegate = await task.value
                return AsyncStream { delegate.registerContinuation($0) }
            },
        )
    }

    public final class Delegate: @unchecked Sendable {
        let continuations: LockIsolated<[UUID: AsyncStream<NetworkMonitorClient.Action>.Continuation]>
        private var queue = DispatchQueue(label: "NetworkMonitorClient")
        private var monitor = NWPathMonitor()

        init() {
            self.continuations = .init([:])
            startMonitoring()
        }

        private func startMonitoring() {
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

                    if isConnected {
                        self.send(.online(connectionType))
                    } else {
                        self.send(.offline(connectionType))
                    }
                }
            }

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
