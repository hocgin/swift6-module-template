//
//  Connectivity.swift
//  App
//
//  Created by hocgin on 2025/6/13.
//


enum Connectivity {
    case online
    case offline
}

struct PathMonitorClient {
    var start: () -> Effect<Connectivity, Never>
    var stop: () -> Effect<Never, Never>
}

extension PathMonitorClient {
    static var live: Self {
        var pathMonitor: NWPathMonitor?
        
        return Self(
            start: {
                .run { subscriber in
                    pathMonitor = NWPathMonitor()
                    
                    pathMonitor?.pathUpdateHandler = { path in
                        switch path.status {
                        case .satisfied:
                            subscriber.send(.online)
                        case .unsatisfied:
                            subscriber.send(.offline)
                        }
                    }
                    
                    pathMonitor?.start(queue: queue)
                    
                    return AnyCancellable {
                        pathMonitor?.cancel()
                        pathMonitor = nil
                    }
                }
            },
            stop: {
                .fireAndForget {
                    pathMonitor?.cancel()
                    pathMonitor = nil
                }
            }
        )
    }
    
    static let mock = Self( /* ... */ )
}

private let queue: DispatchQueue {
    var increment: Int = 0
    defer { increment += 1 }
    return DispatchQueue(label: "PathMonitorQueue-\(increment)")
}
