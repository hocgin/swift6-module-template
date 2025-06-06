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
    let itemWidth: Double = UIScreen.main.bounds.width
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: .zero) {
                ForEach(store.scope(state: \.todos, action: \.todos)) { store in
                    TodoView(store: store)
                        .frame(width: itemWidth)
                        .id(store.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .onAppear {
            store.send(.load)
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
