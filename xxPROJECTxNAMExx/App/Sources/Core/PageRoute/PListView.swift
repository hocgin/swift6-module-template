//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI
import Tagged

@Reducer
struct PList {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var list: IdentifiedArrayOf<ItemState> = []

        struct ItemState: Equatable, Identifiable {
            let id: Tagged<Self, UUID>
            var title: String = ""
        }
    }

    indirect enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case load
        case loaded(String)
        case list(PList.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("PLIST 加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    await send(.loaded(UUID().uuidString))
                }
            case let .loaded(result):
                debugPrint("PLIST 加载完成..\(result)  \(state.list.count)")
                state.list.append(.init(id: .init(), title: result))
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
//        .forEach(\.list, action: \.list) {
//
//        }
    }
}

struct PListView: View {
    @Bindable var store: StoreOf<PList>

    var body: some View {
        List {
            Button("main") {
                @Shared(.route) var route
                $route.withLock { $0.removeAll() }
            }

            Button("TODO") {
                @Shared(.route) var route
                $route.withLock { $0 = .init([.todos(.init())]) }
            }
            .listRowBackground(Color.gray)

            Button("qwebClient") {
                @Shared(.route) var route
                $route.withLock { $0 = .init([.qwebclient(.init())]) }
            }
            .listRowBackground(Color.gray)
        }
        .navigationTitle("PListView")
        .onAppear {
            store.send(.load)
        }
    }
}

/// =======================================================

extension PList.State {
    static let mock: Self = .init()
}

#Preview {
    PListView(
        store: Store(initialState: .mock) { PList() }
    )
}

func x() {}
