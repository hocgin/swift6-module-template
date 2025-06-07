//
//  Schema.swift
//  App
//
//  Created by hocgin on 2025/6/7.
//
import Foundation
import GRDB
import SharingGRDB

@Table("item")
struct Item: Hashable, Identifiable {
    let id: UUID
    var title = ""
    var isInStock = true
    var notes = ""
    var position = 0
}

///
func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
            db.trace(options: .profile) {
                if context == .preview {
                    print("\($0.expandedDescription)")
                } else {
                    debugPrint("\($0.expandedDescription)")
                }
            }
        #endif
    }
    if context == .preview {
        database = try DatabaseQueue(configuration: configuration)
    } else {
        let path =
            context == .live
                ? URL.documentsDirectory.appending(component: "db.sqlite").path()
                : URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
        debugPrint("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    }
    var migrator = DatabaseMigrator()
    #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create initial tables") { db in
        try #sql(
            """
            CREATE TABLE "item" (
              "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
              "title" TEXT NOT NULL,
              "isInStock" INTEGER NOT NULL DEFAULT 0,
              "notes" TEXT NOT NULL DEFAULT "\(raw: UUID().uuidString)",
              "position" INTEGER NOT NULL DEFAULT 0
            )
            """
        )
        .execute(db)
    }

    try migrator.migrate(database)

    /// 预览环境，填充测试数据
    if context == .preview {
        try database.write { db in
            try db.seedSampleData()
        }
    }

    return database
}

#if DEBUG
    extension Database {
        func seedSampleData() throws {
            try seed {
                Item(id: UUID(), title: "title-1", isInStock: true, notes: "Design")
                Item(id: UUID(), title: "title-2", isInStock: true, notes: "Engineering")
                Item(id: UUID(), title: "title-3", isInStock: true, notes: "Product")
            }
        }
    }
#endif
