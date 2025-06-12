import ConcurrencyExtras
import Foundation

extension CustomClient {
    static var live: Self {
        let task = Task<CustomClientSendableBox, Never> { @MainActor in
            let manager = NetworkMonitor()
            let delegate = CustomClientDelegate()
            manager.delegate = delegate
            return .init(delegate: delegate, manager: manager)
        }

        return Self(
            delegate: { @MainActor in
                let delegate = await task.value.delegate
                return AsyncStream { delegate.registerContinuation($0) }
            },
            isConnected: {
                await task.value.manager.isConnected
            },
            getConnectionType: {
                await task.value.manager.connectionType
            },
            forecast: { params in
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                return "forecast.result.\(params)"
            },
            search: { params in
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                return "search.result.\(params)"
            }
        )
    }

    public final class CustomClientDelegate: Sendable {
        let continuations: LockIsolated<[UUID: AsyncStream<CustomClient.Action>.Continuation]>

        init() {
            self.continuations = .init([:])
        }

        func registerContinuation(_ continuation: AsyncStream<CustomClient.Action>.Continuation) {
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

        public func send(_ action: CustomClient.Action) {
            Task { [continuations] in
                continuations.withValue { $0.values.forEach { $0.yield(action) } }
            }
        }
    }

    private struct CustomClientSendableBox: Sendable {
//      @UncheckedSendable var manager: CLLocationManager
        var delegate: CustomClientDelegate
        var manager: NetworkMonitor
    }
}
