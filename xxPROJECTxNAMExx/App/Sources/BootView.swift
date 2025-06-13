//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import Combine
import ComposableArchitecture
import CoreData
import LogHit
import SwiftUI

@Reducer
// @CasePathable
enum AppRoute {
    case main
    case qlocation(QLocation)
    case todos(Todos)
    case pageroute(PageRoute)
    case qdatabase(QDatabase)
    case qwebclient(QWebClient)
    case tpl(Tpl)
    case qscene(QScene)
    case qsheet(QSheet)
    case qshareds(QShareds)
    case customdependencyclient(CustomDependencyClient)
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
        case onAppear
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
            case .onAppear:
                Log.info("~~")
                return .concatenate(
                    .publisher {
                        Future<[String], Never> { promise in
                            DispatchQueue.global().async {
                                let result = "GlobalState.CoreData.listLocation()"
                                Log.info("current = \(Thread.current), isMainThread = \(Thread.isMainThread), Future.init result = \(result)")
                                promise(.success([result]))
                            }
                        }
                        .subscribe(on: DispatchQueue.global(qos: .background))
                        .receive(on: DispatchQueue.global(qos: .background))
                        .map { entities in
                            Log.info("current = \(Thread.current), isMainThread = \(Thread.isMainThread), Future.map.entities = \(entities)")
                            return .skip
                        }
                    }
                )
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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MainView()
        } destination: { store in
            WithPerceptionTracking {
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
                case let .qsheet(store):
                    QSheetView(store: store)
                case let .qshareds(store):
                    QSharedsView(store: store)
                case let .customdependencyclient(store):
                    CustomDependencyClientView(store: store)
                default:
                    ErrorView()
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
//        .environment(\.path, store.path)
    }
}
