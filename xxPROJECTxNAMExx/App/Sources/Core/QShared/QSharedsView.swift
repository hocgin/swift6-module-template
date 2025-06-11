//
//  QShareds.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct QShareds {
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var QShareds: IdentifiedArrayOf<Todo.State> = []
        var selectedID: String?
    }

    indirect enum Action: BindableAction, Sendable {
        case addTodoButtonTapped
        case binding(BindingAction<State>)
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedQShareds
        case QShareds(IdentifiedActionOf<Todo>)
        case appendAll([Todo.State])
        case load
        case todo(QShareds.Action)
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
                state.QShareds.append(contentsOf: arr)
                if state.selectedID == nil {
                    state.selectedID = state.QShareds.ids.first
                }
                return .none

            case let .delete(indexSet):
                for index in indexSet {
                    state.QShareds.remove(id: state.QShareds[index].id)
                }
                return .none

            case var .move(source, destination):
//                if state.filter == .completed {
                source = IndexSet(
                    source
                        .map { state.QShareds[$0] }
                        .compactMap { state.QShareds.index(id: $0.id) }
                )
                destination =
                    (destination < state.QShareds.endIndex
                        ? state.QShareds.index(id: state.QShareds[destination].id)
                        : state.QShareds.endIndex)
                    ?? destination
//                }

                state.QShareds.move(fromOffsets: source, toOffset: destination)

                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(100))
                    await send(.sortCompletedQShareds)
                }

            case .sortCompletedQShareds:
                state.QShareds.sort { $1.isComplete && !$0.isComplete }
                return .none

            case let .QShareds(.element(id: _, action: .addData(data))):
                debugPrint("data = \(data)")
                state.QShareds.append(Todo.State(
                    id: UUID().uuidString,
                    description: "\(data)"
                ))
                return .none

            default:
                let _ = debugPrint("default = ")
                return .none
            }
        }
        .forEach(\.QShareds, action: \.QShareds) {
            let _ = debugPrint("QShareds.QShareds")
            Todo()
        }
    }
}

struct QSharedsView: View {
    @Bindable var store: StoreOf<QShareds>
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
                    ForEach(store.scope(state: \.QShareds, action: \.QShareds), id: \.state.id) { store in
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
                    let store = store.scope(state: \.QShareds[id: selectedID], action: \.todo)
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
        @Bindable var store: Store<Todo.State?, QShareds.Action>

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
    QSharedsView(
        store: Store(initialState: QShareds.State(QShareds: .mock)) {
            QShareds()
        }
    )
}
