//
//  Todos.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation

@Reducer
struct Todos {
    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo.State> = []
    }

    enum Action: BindableAction, Sendable {
        case addTodoButtonTapped
        case binding(BindingAction<State>)
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedTodos
        case todos(IdentifiedActionOf<Todo>)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    private enum CancelID { case todoCompletion }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
//            case .addTodoButtonTapped:
//                let _ = debugPrint("state = \(state)")
//                return .none

            case let .delete(indexSet):
                for index in indexSet {
                    state.todos.remove(id: state.todos[index].id)
                }
                return .none

            case var .move(source, destination):
//                if state.filter == .completed {
                source = IndexSet(
                    source
                        .map { state.todos[$0] }
                        .compactMap { state.todos.index(id: $0.id) }
                )
                destination =
                    (destination < state.todos.endIndex
                        ? state.todos.index(id: state.todos[destination].id)
                        : state.todos.endIndex)
                    ?? destination
//                }

                state.todos.move(fromOffsets: source, toOffset: destination)

                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(100))
                    await send(.sortCompletedTodos)
                }

            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none

            default:
                let _ = debugPrint("default = \(state)")
                return .none
            }
        }
        .forEach(\.todos, action: \.todos) {
            Todo()
        }
    }
}
