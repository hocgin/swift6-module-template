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
    @ObservableState
    struct State: Equatable {
        @Shared(.sharedsItems) var items: IdentifiedArrayOf<QShared.State> = []
        var selectedID: String?
    }

    indirect enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case items(IdentifiedActionOf<QShared>)
        case item(QShareds.Action)
        case appendAll([QShared.State])
        case load
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .load:
                debugPrint("加载所有数据..")
                return .run { send in
                    let result: [QShared.State] = (try? await Task {
                        try await Task.sleep(nanoseconds: 600000)
                        return [
                            QShared.State(id: UUID().uuidString, description: "1"),
                            QShared.State(id: UUID().uuidString, description: "2"),
                            QShared.State(id: UUID().uuidString, description: "3"),
                        ]
                    }.value) ?? []
                    await send(.appendAll(result))
                }
            case let .items(.element(id: _, action: .addData(result))):
                let _ = debugPrint("items = \(state.items.count)")
                state.$items.withLock {
                    $0.append(QShared.State(id: UUID().uuidString, description: result))
                }
                return .none
            default:
                let _ = debugPrint("default = ")
                return .none
            }
        }
        .forEach(\.items, action: \.items) {
            QShared()
        }
        .onChange(of: \.items) { oldValue, newValue in
            Reduce { state, action in
                _ = state
                _ = action
                debugPrint("old: \(oldValue), new: \(newValue)")
                return .none
            }
        }
        ._printChanges()
    }
}

struct QSharedsView: View {
    @Bindable var store: StoreOf<QShareds>
    let itemWidth: Double = UIScreen.main.bounds.width
    @State var id: String?
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: .zero) {
                    ForEach(store.scope(state: \.items, action: \.items), id: \.state.id) { store in
                        QSharedView(store: store)
                            .frame(width: itemWidth)
                    }
                }
            }
            .scrollPosition(id: $store.selectedID)
        }
        .onAppear {
            store.send(.load)
        }
    }
}

extension IdentifiedArrayOf<QShared.State> {
    static let mock: Self = [
        QShared.State(
            id: UUID().uuidString,
            description: "Check Mail",
            isComplete: false
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Buy Milk",
            isComplete: false
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
        QShared.State(
            id: UUID().uuidString,
            description: "Call Mom",
            isComplete: true
        ),
    ]
}

#Preview {
    QSharedsView(
        store: Store(initialState: QShareds.State(items: .mock)) {
            QShareds()
        }
    )
}
