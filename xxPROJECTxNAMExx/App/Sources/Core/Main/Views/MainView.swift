//
//  MainView.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Todos>
    var body: some View {
        List {
            ForEach(store.scope(state: \.todos, action: \.todos)) { store in
                TodoView(store: store)
            }
            .onDelete { store.send(.delete($0)) }
            .onMove { store.send(.move($0, $1)) }
        }
    }
}

extension IdentifiedArrayOf<Todo.State> {
    static let mock: Self = [
        Todo.State(
            description: "Check Mail",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Buy Milk",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Call Mom",
            id: UUID(),
            isComplete: true
        ),
    ]
}

#Preview {
    MainView(
        store: Store(initialState: Todos.State(todos: .mock)) {
            Todos()
        }
    )
}
