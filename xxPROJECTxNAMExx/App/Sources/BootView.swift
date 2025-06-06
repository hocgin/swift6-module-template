//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import ComposableArchitecture
import CoreData
import SwiftUI
import Voyager

enum AppRoute: Route {
    case main
}

struct BootView: View {
    @Bindable var store: StoreOf<Todos>
    @EnvironmentObject var router: Router<AppRoute>

    var body: some View {
        NavVoyagerView(router: router) { route in
            switch route {
            case .main:
                MainView(store: store)
            default: Text("default View")
            }
        }
    }
}
