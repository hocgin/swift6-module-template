//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import CoreData
import SwiftUI
import Voyager

enum AppRoute: Route {
    case main
}

@Reducer
struct Boot {
    @Reducer
    enum Path {
        case main
        case todos(Todos)
        case pageroute(PageRoute)
        case qdatabase
        case qwebclient(QWebClient)
        case tpl(Tpl)
    }

    @ObservableState
    struct State: Equatable {
        var todos: Todos.State = .init()
        var path = StackState<Path.State>()
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case todos(Todos.Action)
        case skip
    }

    var body: some ReducerOf<Self> {
//        Scope(state: \.todos, action: \.todos) {
//            Todos()
//        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            default:
                _ = state
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension Boot.Path.State: Equatable {}

struct BootView: View {
    @Bindable var store: StoreOf<Boot>

    var body: some View {
        let path = $store.scope(state: \.path, action: \.path)
        NavigationStack(path: path) {
            MainView()
        } destination: { store in
            switch store.case {
            case let .todos(store):
                TodosView(store: store)
            case let .qwebclient(store):
                QWebClientView(store: store)
            case .qdatabase:
                QDatabaseView()
            case let .pageroute(store):
                PageRouteView(store: store)
            case .main:
                MainView()
            case let .tpl(store):
                TplView(store: store)
            default:
                ErrorView()
            }
        }
    }
}
