//
//  ContentView.swift
//  iOS Example
//
//  Created by __AUTHOR NAME__ on __TODAYS_DATE__.
//

import CoreData
import SwiftHit
import SwiftUI
import Voyager

enum AppRoute: Route {
    case main
}

struct BootView: View {
    @StateObject var router = Router<AppRoute>(root: .main)

    var body: some View {
        NavVoyagerView(router: router) { route in
            switch route {
            case .main: Text("Main View")
            default: Text("default View")
            }
        }
    }
}

#Preview {
    BootView()
}
