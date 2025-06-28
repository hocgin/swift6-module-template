//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//
import CasePaths
import ComposableArchitecture
import Dependencies
import SwiftLogKit
import SwiftUI

@Reducer
struct Boot {
    /// 状态
    @ObservableState struct State {
        @Shared(.path) var path
        @Presents var destination: Destination.State?
    }

    /// 弹窗
    @Reducer enum Destination {}

    /// 事件
    enum Action: Sendable {
        case onAppear
        case path(StackActionOf<AppPath>)
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct BootView: View {
    @Bindable var store: StoreOf<Boot>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MainView()
        } destination: { store in
            WithPerceptionTracking {
                switch store.case {
                case .main: MainView()
                case let .error(store): AsErrorView(store: store)
                default:
                    Text("not found AppPath = \(store.case) View")
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
