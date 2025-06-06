//
//  WebClient.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture

@DependencyClient
struct WebClient {
    var forecast: @Sendable (_ location: String) async throws -> String
    var search: @Sendable (_ query: String) async throws -> String
}

extension WebClient: DependencyKey {
    static let liveValue = WebClient(
        forecast: { params in
            "forecast.result.\(params)"
        },
        search: { params in
            "search.result.\(params)"
        }
    )
}

extension DependencyValues {
    var webClient: WebClient {
        get { self[WebClient.self] }
        set { self[WebClient.self] = newValue }
    }
}

/// ======
extension WebClient: TestDependencyKey {
    static let previewValue = Self(
        forecast: { _ in "forecast.mock" },
        search: { _ in "search.mock" }
    )

    static let testValue = Self()
}
