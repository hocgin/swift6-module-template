//
//  MainView.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import ComposableArchitecture
import SwiftUI
import SwiftUIError

@Reducer
struct Main {
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

struct MainView: View {
    @Bindable var store: StoreOf<Main>

    var body: some View {
        Button("Error View") {
            withPathError {
                throw AppError.unknown
            }
        }
        .buttonStyle(.bordered)

        Button("Toast") {
            withToastError {
                throw AppError.unknown
            }
        }
        .buttonStyle(.bordered)

        Button("PayWall") {
            withPath(.paywall(.init()))
        }
        .buttonStyle(.bordered)
    }
}
