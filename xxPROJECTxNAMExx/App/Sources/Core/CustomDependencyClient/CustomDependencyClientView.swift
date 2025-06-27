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
    @Dependency(\.networkMonitorClient.isOnline) var testIsOnline

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
        case networkMonitorClient2
    }

    @ReducerBuilder<State, Action>
    var CustomClientReducer: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .customClient(.didUpdateConnected(isConnected, type)):
                debugPrint("isConnected = \(isConnected), type = \(type)")
//                state.isConnected = isConnected
                return .none
            case let .networkMonitorClient(type):
                debugPrint("networkMonitorClient: status = \(type)")
                switch type {
                case .online:
                    state.isConnected = true
                default:
                    state.isConnected = false
                }
                return .none
            default:
                return .none
            }
        }

//        .onChange(of: customClient.isConnected ?? false) {}
    }

    var body: some ReducerOf<Self> {
        CustomClientReducer
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    do {
//                        for await status in try await networkMonitorClient.statusStream() {
//                            debugPrint("---> status = \(status)")
//                            await send(.networkMonitorClient(status ? .online : .offline))
//                        }

                        for await action in await networkMonitorClient.delegate() {
                            debugPrint("---> status = \(action)")
                            await send(.networkMonitorClient(action))
                        }

                    } catch {}
                }
//                return .concatenate(
//                    .run { send in
//                        await withTaskGroup(of: Void.self) { group in
//                            group.addTask {
//                                await withTaskCancellation(
//                                    id: CancelID.customClient,
//                                    cancelInFlight: true
//                                ) {
//                                    for await action in await customClient.delegate() {
//                                        await send(.customClient(action))
//                                    }
//                                }
//                            }
//                            group.addTask {
//                                await withTaskCancellation(
//                                    id: CancelID.networkMonitorClient,
//                                    cancelInFlight: false
//                                ) {
//                                    for await action in await networkMonitorClient.delegate() {
//                                        await send(.networkMonitorClient(action))
//                                    }
//                                }
//                            }
//
//                            group.addTask {
//                                await withTaskCancellation(
//                                    id: CancelID.networkMonitorClient2,
//                                    cancelInFlight: false
//                                ) {
//                                    do {
//                                        for await status in try await networkMonitorClient.statusStream() {
//                                            await send(.networkMonitorClient(status ? .online : .offline))
//                                        }
//                                    } catch {}
//                                }
//                            }
//                        }
//                    }
//                )
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
//        .onChange(of: customClient., <#T##reducer: (Equatable, Equatable) -> Reducer##(Equatable, Equatable) -> Reducer##(_ oldValue: Equatable, _ newValue: Equatable) -> Reducer#>)
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
