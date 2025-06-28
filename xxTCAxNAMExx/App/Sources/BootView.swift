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

// @Reducer
// extension AppRoute.State: Equatable {}

@Reducer
struct Boot {
    @ObservableState
    struct State: Equatable {
        @Shared(.path) var path
    }

    enum Action: Sendable {
        case path(StackActionOf<AppPath>)
    }

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct BootView: View {
    @Bindable var store: StoreOf<Boot>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MainView()
        } destination: { store in
            WithPerceptionTracking {
                Text("\(store.case)")
            }
        }
    }
}
