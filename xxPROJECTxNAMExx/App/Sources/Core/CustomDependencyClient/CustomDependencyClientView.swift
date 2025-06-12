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
struct CustomDependencyClient {
    @Dependency(\.customClient) var customClient
    @Dependency(\.networkMonitorClient) var networkMonitorClient

    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        var isConnected: Bool?
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case loaded(String)
        case customClient(CustomClient.Action)
        case networkMonitorClient(NetworkMonitorClient.Action)
    }

    enum CancelID: Int {
        case customClient
        case networkMonitorClient
    }

    @ReducerBuilder<State, Action>
    var CustomClientReducer: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .customClient(.didUpdateConnected(isConnected, type)):
                debugPrint("isConnected = \(isConnected), type = \(type)")
                state.isConnected = isConnected
                return .none
            case let .networkMonitorClient(status):
                debugPrint("networkMonitorClient: status = \(status)")
//                state.isConnected = isConnected
                return .none
            default:
                return .none
            }
        }
    }

    var body: some ReducerOf<Self> {
        CustomClientReducer
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .concatenate(
                    .run { send in
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask {
                                await withTaskCancellation(
                                    id: CancelID.customClient,
                                    cancelInFlight: true
                                ) {
                                    for await action in await customClient.delegate() {
                                        await send(.customClient(action))
                                    }
                                }
                            }
                            group.addTask {
                                await withTaskCancellation(
                                    id: CancelID.networkMonitorClient,
                                    cancelInFlight: true
                                ) {
                                    for await action in await networkMonitorClient.delegate() {
                                        await send(.networkMonitorClient(action))
                                    }
                                }
                            }
                        }
                    }
                )
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

struct CustomDependencyClientView: View {
    @Bindable var store: StoreOf<CustomDependencyClient>

    var body: some View {
        VStack {
            Text("Todo.\(store.id)")
            Text("isConnected.\(store.isConnected)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =======================================================

extension CustomDependencyClient.State {
    static let mock: Self = .init()
}

#Preview {
    CustomDependencyClientView(
        store: Store(initialState: .mock) { CustomDependencyClient() }
    )
}
