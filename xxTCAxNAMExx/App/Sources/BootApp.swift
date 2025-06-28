//
//  ExampleApp.swift
//  Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import SharingGRDB
import SwiftNetworkKit
import SwiftUI

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

    @Environment(\.dismiss) var dismiss
    var body: some Scene {
        WindowGroup {
            BootView(store: BootApp.store)
                .askAppGuide()
                .askAppChangeLog(toPaywall)
                .askNetworkMonitor()
        }
    }

    private func toPaywall() {
        debugPrint("---> Go Pay")
        dismiss()
    }
}
