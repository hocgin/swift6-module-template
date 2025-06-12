//
//  NetworkMonitor.swift
//  InternetConnectivity
//
//  Created by Balaji Venkatesh on 16/04/25.
//

import Network
import SwiftUI

public extension EnvironmentValues {
    @Entry var isNetworkConnected: Bool?
    @Entry var connectionType: NWInterface.InterfaceType?
}

public class NetworkMonitor: ObservableObject, @unchecked Sendable {
    @Published public var isConnected: Bool?
    @Published public var connectionType: NWInterface.InterfaceType?
    public var delegate: CustomClient.CustomClientDelegate?
    
    /// Monitor Properties
    private var queue = DispatchQueue(label: "Monitor")
    private var monitor = NWPathMonitor()
    
    public init() {
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
                self.isConnected = isConnected
                self.connectionType = connectionType
                
                self.delegate?.send(.didUpdateConnected(isConnected, connectionType))
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
