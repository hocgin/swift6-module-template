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
struct QSheetCh {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case loaded(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
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

struct QSheetChView: View {
    @Bindable var store: StoreOf<QSheetCh>

    var body: some View {
        VStack {
            Text("Todo.\(store.id)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =======================================================

extension QSheetCh.State {
    static let mock: Self = .init()
}

#Preview {
    QSheetChView(
        store: Store(initialState: .mock) { QSheetCh() }
    )
}
