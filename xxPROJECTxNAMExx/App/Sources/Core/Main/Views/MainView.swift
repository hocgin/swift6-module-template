//
//  MainView.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import ExtensionHit
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<Todos>
    let itemWidth: Double = UIScreen.main.bounds.width
    @State var id: String?
    var body: some View {
        VStack {
            Text("ID:\(store.selectedID)")
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
                    HeaderView(store: store.scope(
                        state: \.todos[id: selectedID],
                        action: \.todo
                    ))
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
                return Text("\(description)")
            }
        }
    }
}

extension IdentifiedArrayOf<Todo.State> {
    static let mock: Self = [
        Todo.State(
            description: "Check Mail",
            id: UUID().uuidString,
            isComplete: false
        ),
        Todo.State(
            description: "Buy Milk",
            id: UUID().uuidString,
            isComplete: false
        ),
        Todo.State(
            description: "Call Mom",
            id: UUID().uuidString,
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
