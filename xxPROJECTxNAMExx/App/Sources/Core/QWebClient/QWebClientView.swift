//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct QWebClient {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        var result: String = ""
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case load
        case loaded(String)
    }

    @Dependency(\.webClient) var webClient

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    let result = (try? await webClient.search(query: "模拟请求网络")) ?? "fail"
                    await send(.loaded(result))
                }
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                state.result = result
                return .none
            default:
                return .none
            }
        }
    }
}

struct QWebClientView: View {
    @Bindable var store: StoreOf<QWebClient>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Todo.\(store.id)")
            Text("请求状态: \(store.isLoading ? "加载中" : "加载完成")")
            Text("请求结果: \(store.result)")
            Button("点击请求") {
                store.send(.load)
            }
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
