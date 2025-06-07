//
//  DatabaseView.swift
//  App
//
//  Created by hocgin on 2025/6/7.
//
import ComposableArchitecture
import SharingGRDB
import SwiftUI

@Reducer
struct QDatabase {
    @ObservableState
    struct State: Equatable {
        var items: [Item] = []
    }

    enum Action {
        case onAppear
        case seedDatabase
        case delete(IndexSet)
        case move(IndexSet, Int)
        case items([Item])
    }

    @ObservationIgnored @Dependency(\.defaultDatabase) var database

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            /// 查询
            case .onAppear:
                let _ = state
                debugPrint("加载项 新数据..")
                return .run { send in
                    await withErrorReporting {
                        let items = try await database.read { db in
                            try Item.order { $0.position.asc() }.fetchAll(db)
                        }
                        await send(.items(items))
                    }
                }
            /// 增
            case .seedDatabase:
                withErrorReporting {
                    try database.write { db in
                        try db.seedSampleData()
                    }
                }

                return .run { send in
                    await send(.onAppear)
                }
            /// 删
            case let .delete(indices):
                withErrorReporting {
                    try database.write { db in
                        let ids = indices.map { state.items[$0].id }
                        try Item
                            .where { $0.id.in(ids) }
                            .delete()
                            .execute(db)
                    }
                }
                return .run { send in
                    await send(.onAppear)
                }
            /// 改
            case let .move(source, destination):
                var mids = state.items.map(\.id)
                mids.move(fromOffsets: source, toOffset: destination)
                return .concatenate(
                    .run { [ids = mids] _ in
                        withErrorReporting {
                            try database.write { db in
                                try Item
                                    .where { $0.id.in(ids) }
                                    .update {
                                        let ids = Array(ids.enumerated())
                                        let (first, rest) = (ids.first!, ids.dropFirst())
                                        $0.position =
                                            rest.reduce(Case($0.id).when(first.element, then: first.offset)) { cases, id in
                                                cases.when(id.element, then: id.offset)
                                            }
                                            .else($0.position)
                                    }
                                    .execute(db)
                            }
                        }
                    },
                    .run { send in
                        await send(.onAppear)
                    }
                )
            case let .items(items):
                state.items = items
                return .none
            default:
                return .none
            }
        }
    }
}

struct QDatabaseView: View {
    @Bindable var store: StoreOf<QDatabase>

    var body: some View {
        List {
            ForEach(store.items) { item in
                Text("item - \(item.title)")
            }
            .onDelete { store.send(.delete($0)) }
            .onMove { store.send(.move($0, $1)) }
        }
        .toolbar {
#if DEBUG
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button {
                        store.send(.seedDatabase)
                    } label: {
                        Text("Seed data")
                        Image(systemName: "leaf")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
#endif
        }
        .navigationTitle("QDatabase")
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =====

extension QDatabase.State {
    static let mock: Self = .init()
}

#Preview {
    Group {
        let _ = try? prepareDependencies {
            $0.defaultDatabase = try appDatabase()
        }
        NavigationStack {
            QDatabaseView(
                store: Store(initialState: .mock) { QDatabase() }
            )
        }
    }
}
