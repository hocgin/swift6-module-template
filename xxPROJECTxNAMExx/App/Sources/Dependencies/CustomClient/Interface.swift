//
//  CustomClient.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import HTTPRequestKit
import Network

@DependencyClient
public struct CustomClient: Sendable {
    public var delegate: @Sendable () async -> AsyncStream<Action> = { .never }
    ///
    var forecast: @Sendable (_ location: String) async throws -> String
    var search: @Sendable (_ query: String) async throws -> String

    public enum Action: Equatable, Sendable {
        case didUpdateConnected(Bool?, NWInterface.InterfaceType?)
    }
}
