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
        @FetchAll var items: [Item]
    }

    enum Action {
        case onAppear
        case seedDatabase
    }

    @ObservationIgnored @Dependency(\.defaultDatabase) var database

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let _ = state
                debugPrint("加载项 新数据..")
                return .none
            case .seedDatabase:
                withErrorReporting {
                    try database.write { db in
                        try db.seedSampleData()
                    }
                }
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
