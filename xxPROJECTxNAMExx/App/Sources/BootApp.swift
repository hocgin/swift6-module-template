//
//  ExampleApp.swift
//  Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import SwiftUI
import Voyager

@main
struct BootApp: App {
    @StateObject var router = Router<AppRoute>(root: .main)
    static let store = Store(initialState: Todos.State()) { Todos() }

    var body: some Scene {
        WindowGroup {
            BootView(store: Self.store)
        }
    }
}
