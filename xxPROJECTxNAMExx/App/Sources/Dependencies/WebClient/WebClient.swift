//
//  WebClient.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture

@DependencyClient
struct WebClient: Sendable {
    var forecast: @Sendable (_ location: String) async throws -> String
    var search: @Sendable (_ query: String) async throws -> String
}

extension WebClient: DependencyKey {
    static let liveValue = WebClient(
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
