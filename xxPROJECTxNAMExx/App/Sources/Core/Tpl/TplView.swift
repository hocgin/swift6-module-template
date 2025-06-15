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
    struct State: Equatable {}

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
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
//            Text("Todo.\(store.id)")
//            Text("\(store.isLoading ? "加载中" : "加载完成")")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =======================================================

extension Tpl.State {
    static let mock: Self = .init()
}

#Preview {
    TplView(
        store: Store(initialState: .mock) { Tpl() }
    )
}
