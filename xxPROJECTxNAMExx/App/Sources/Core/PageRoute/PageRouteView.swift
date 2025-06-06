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
struct PageRoute {
    @Reducer
    enum Path {
        case todo(Todo)
        case qwebClient(QWebClient)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var isLoading: Bool = false
        var children = PList.State()
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case load
        case loaded(String)
        case children(PList.Action)
    }

    var body: some ReducerOf<Self> {
        /// 关乎是否触发子视图变动
        Scope(state: \.children, action: \.children) {
            PList()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(nanoseconds: 6_000_000_000)
                    await send(.loaded(UUID().uuidString))
                }
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                return .none
            case .path:
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension PageRoute.Path.State: Equatable {}

struct PageRouteView: View {
    @Bindable var store: StoreOf<PageRoute>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            PListView(store: store.scope(state: \.children, action: \.children))
        } destination: { store in
            switch store.case {
            case let .todo(store):
                TodoView(store: store)
            case let .qwebClient(store):
                QWebClientView(store: store)
            }
        }
        .onAppear {
            store.send(.load)
        }
    }
}

/// =======================================================

extension PageRoute.State {
    static let mock: Self = .init()
}

#Preview {
    PageRouteView(
        store: Store(initialState: .mock) { PageRoute() }
    )
}
