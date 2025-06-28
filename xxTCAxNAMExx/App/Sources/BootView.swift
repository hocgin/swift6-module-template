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
    @Reducer enum Destination {
        case paywall(PayWall)
    }

    /// 事件
    enum Action: Sendable {
        case onAppear
        case path(StackActionOf<AppPath>)
        case destination(PresentationAction<Destination.Action>)
        case open(Destination.State?)
    }

    var body: some ReducerOf<Self> {
        Reduce { store, action in
            switch action {
            case let .open(destination):
                store.destination = destination
                return .none
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
            MainView(store: .init(initialState: Main.State(), reducer: Main.init))
        } destination: { store in
            WithPerceptionTracking {
                switch store.case {
                case let .main(store): MainView(store: store)
                case let .paywall(store): PayWallView(store: store)
                case let .error(store): AsErrorView(store: store)
                default: Text("not found AppPath = \(store.case) View")
                }
            }
        }
        .sheet(item: $store.scope(state: \.destination?.paywall, action: \.destination.paywall), content: PayWallView.init)
        .onAppear { store.send(.onAppear) }
    }
}
