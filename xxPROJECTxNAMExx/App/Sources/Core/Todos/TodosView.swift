//
//  Todos.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct Todos {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo.State> = []
        var selectedID: String?
    }

    indirect enum Action: BindableAction, Sendable {
        case addTodoButtonTapped
        case binding(BindingAction<State>)
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedTodos
        case todos(IdentifiedActionOf<Todo>)
        case appendAll([Todo.State])
        case load
        case todo(Todos.Action)
    }

    private enum CancelID { case todoCompletion }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载所有数据..")
                return .run { send in
                    let result: [Todo.State] = (try? await Task {
                        try await Task.sleep(nanoseconds: 600000)
                        return [
                            Todo.State(id: UUID().uuidString, description: "1"),
                            Todo.State(id: UUID().uuidString, description: "2"),
                            Todo.State(id: UUID().uuidString, description: "3"),
                        ]
                    }.value) ?? []
                    await send(.appendAll(result))
                }

            case let .appendAll(arr):
                state.todos.append(contentsOf: arr)
                if state.selectedID == nil {
                    state.selectedID = state.todos.ids.first
                }
                return .none

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

            case let .todos(.element(id: _, action: .addData(data))):
                debugPrint("data = \(data)")
                state.todos.append(Todo.State(
                    id: UUID().uuidString,
                    description: "\(data)"
                ))
                return .none

            default:
                let _ = debugPrint("default = ")
                return .none
            }
        }
        .forEach(\.todos, action: \.todos) {
            let _ = debugPrint("Todos.todos")
            Todo()
        }
    }
}

struct TodosView: View {
    @Bindable var store: StoreOf<Todos>
    let itemWidth: Double = UIScreen.main.bounds.width
    @State var id: String?
    var body: some View {
        VStack(alignment: .leading) {
            Text("ID:\(store.selectedID ?? "nil")")
                .padding(.top)
                .padding(.top)
                .foregroundStyle(.red)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: .zero) {
                    ForEach(store.scope(state: \.todos, action: \.todos), id: \.state.id) { store in
                        TodoView(store: store)
                            .frame(width: itemWidth)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $store.selectedID)
            .scrollTargetBehavior(.paging)
        }
        .overlay(alignment: .top) {
            Group {
                if let selectedID = store.selectedID {
                    let store = store.scope(state: \.todos[id: selectedID], action: \.todo)
                    HeaderView(store: store)
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            store.send(.load)
        }
    }

    struct HeaderView: View {
        @Bindable var store: Store<Todo.State?, Todos.Action>

        var body: some View {
            WithViewStore(store, observe: { $0 }) { store in
                let description = store.optional?.description
                return Text("\(description ?? "")")
            }
        }
    }
}

extension IdentifiedArrayOf<Todo.State> {
    static let mock: Self = [
        Todo.State(
            id: UUID().uuidString,
            description: "Check Mail",
            isComplete: false
        ),
        Todo.State(
            id: UUID().uuidString,
            description: "Buy Milk",
            isComplete: false
        ),
        Todo.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
    ]
}

#Preview {
    TodosView(
        store: Store(initialState: Todos.State(todos: .mock)) {
            Todos()
        }
    )
}
