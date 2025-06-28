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
struct PayWall {
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

struct PayWallView: View {
    @Bindable var store: StoreOf<PayWall>

    var body: some View {
        VStack {
            Text("PayWall")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =======================================================

extension PayWall.State {
    static let mock: Self = .init()
}

#Preview {
    PayWallView(
        store: Store(initialState: .mock) { PayWall() }
    )
}
