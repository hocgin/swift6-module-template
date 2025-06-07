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
struct QScene {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        var title = "未初始化"
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case background
        case loaded(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("加载项 新数据..")
                state.title = "加载中"
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(nanoseconds: 6_000_000_000)
                    await send(.loaded(UUID().uuidString))
                }
            case let .loaded(result):
                state.title = "加载完成"
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                return .none
            case .background:
                state.title = "后台刷新"
                debugPrint("后台刷新")
                return .none
            default:
                return .none
            }
        }
    }
}

struct QSceneView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var store: StoreOf<QScene>

    var body: some View {
        VStack {
            Text("Todo.\(store.id)")
            Text("\(store.title)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
        }
        .onAppear { store.send(.onAppear) }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .inactive && newPhase == .active {
                store.send(.background)
            }
        }
    }
}

/// =======================================================

extension QScene.State {
    static let mock: Self = .init()
}

#Preview {
    QSceneView(
        store: Store(initialState: .mock) { QScene() }
    )
}
