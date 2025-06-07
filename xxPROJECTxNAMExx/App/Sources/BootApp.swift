//
//  ExampleApp.swift
//  Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import SharingGRDB
import SwiftUI
import Voyager

@main
struct BootApp: App {
    @Dependency(\.context) var context
    static let store = Store(initialState: Boot.State()) { Boot() }
    init() {
        if context == .live {
            prepareDependencies {
                $0.defaultDatabase = try! appDatabase()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            BootView(store: Self.store)
        }
    }
}
