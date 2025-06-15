//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import CacheKit
import ComposableArchitecture
import Foundation
import SwiftUI

// import HTTP

@Reducer
struct QWebClient {
    @Dependency(\.webClient) var webClient

    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        var result: String = ""
        var search: String = ""
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case load
        case loaded(String)
        case search(String)
    }

    enum CancelID { case search }

    @Dependency(\.mainQueue) var mainQueue
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    try await CacheKit.useStale(forKey: "test", promise: { (result: String?) in
                        guard let result else { return }
                        Task { await send(.loaded("\(result)_\(UUID().uuidString)")) }
                    }) { (try? await webClient.search(query: "模拟请求网络")) ?? "fail" }
                }
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                state.result = result
                return .none
            case let .search(query):
                return .run { _ in
                    debugPrint("搜索..\(query)")
                }
                .debounce(id: CancelID.search, for: .milliseconds(800), scheduler: mainQueue)
            default:
                return .none
            }
        }
    }
}

struct QWebClientView: View {
    @Bindable var store: StoreOf<QWebClient>

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Todo.\(store.id)")
                Text("请求状态: \(store.isLoading ? "加载中" : "加载完成")")
                Text("请求结果: \(store.result)")
                Button("点击请求") {
                    store.send(.load)
                }
            }
        }
        .searchable(
            text: $store.search,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onChange(of: store.search) { _, query in
            debugPrint("搜索")
            store.send(.search(query))
        }
        .onAppear {
            store.send(.load)
        }
    }
}

/// =====

extension QWebClient.State {
    static let mock: Self = .init()
}

#Preview {
    QWebClientView(
        store: Store(initialState: .mock) { QWebClient() }
    )
}
