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
struct Tpl {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case load
        case loaded(String)
    }

    var body: some ReducerOf<Self> {
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
            default:
                return .none
            }
        }
    }
}

struct TplView: View {
    @Bindable var store: StoreOf<Tpl>

    var body: some View {
        VStack {
            Text("Todo.\(store.id)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
        }
        .onAppear {
            store.send(.load)
        }
    }
}

/// =====

extension Tpl.State {
    static let mock: Self = .init()
}

#Preview {
    TplView(
        store: Store(initialState: .mock) { Tpl() }
    )
}
