//
//  QShared.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct QShared {
    @ObservableState
    struct State: Equatable, Identifiable {
        public let id: String
        var description = ""
        var isComplete = false
        var isLoading = false
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case load
        case loaded(String)
        case addData(String)
        case updateData(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载项 \(state.description) 新数据..")
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(nanoseconds: 6_000_000_000)
                    await send(.loaded(UUID().uuidString))
                }
            case let .loaded(result):
//                state.description = result
                state.isLoading = false
                return .none
            case let .updateData(result):
                state.description = "updateData \(result)"
                return .none
            case let .addData(result):
                debugPrint("新增数据: \(result)")
//                @Shared(.sharedsItems) var items
//                $items.withLock {
//                    _ = $0.append(QShared.State(id: UUID().uuidString, description: result))
//                }
//                debugPrint("当前数据: \(items.count)")
                return .none
            default:
                return .none
            }
        }
        ._printChanges()
    }
}

struct QSharedView: View {
    @Bindable var store: StoreOf<QShared>
    var body: some View {
        VStack {
            Text("QShared.\(store.id)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
            Text("description.\(store.description)")
            Button("新增") {
                store.send(.addData("子节点新增的数据"))
            }
            Button("更新") {
                store.send(.updateData("xx"))
            }
        }
        .onAppear {
            store.send(.load)
        }
    }
}
