//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import CoreData
import SwiftUI

@Reducer
enum AppRoute {
    case main
    case qlocation(QLocation)
    case todos(Todos)
    case pageroute(PageRoute)
    case qdatabase(QDatabase)
    case qwebclient(QWebClient)
    case tpl(Tpl)
    case qscene(QScene)
}

extension AppRoute.State: Equatable {}

@Reducer
struct Boot {
    @ObservableState
    struct State: Equatable {
        @Shared(.route) var path
        var todos: Todos.State = .init()
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case path(StackActionOf<AppRoute>)
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

struct BootView: View {
    @Bindable var store: StoreOf<Boot>

    var body: some View {
        let path = $store.scope(state: \.path, action: \.path)
        NavigationStack(path: path) {
            MainView()
        } destination: { store in
            switch store.case {
            case .main:
                MainView()
            case let .qscene(store):
                QSceneView(store: store)
            case let .todos(store):
                TodosView(store: store)
            case let .qwebclient(store):
                QWebClientView(store: store)
            case let .qdatabase(store):
                QDatabaseView(store: store)
            case let .pageroute(store):
                PageRouteView(store: store)
            case let .qlocation(store):
                QLocationView(store: store)
            case let .tpl(store):
                TplView(store: store)
            default:
                ErrorView()
            }
        }
//        .environment(\.path, store.path)
    }
}
