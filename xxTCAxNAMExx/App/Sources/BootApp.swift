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
import SwiftUIStoreUI

@main
struct BootApp: App {
    @Dependency(\.context) var context
    static var storeContext = StoreContext(productIds: [
        "in.hocg.app.weather.weak.20250306",
        "in.hocg.app.weather.monthly.20250306",
        "in.hocg.app.weather.annual.20250306",
        "in.hocg.app.weather.lifetime.20250306",
    ], onUpdatePurchased: { hasNotPurchased in
        debugPrint("onUpdatePurchased.hasNotPurchased = \(hasNotPurchased)")
    })
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
        .environmentObject(BootApp.storeContext)
    }

    private func toPaywall() {
        debugPrint("---> Go Pay")
        dismiss()
    }
}
