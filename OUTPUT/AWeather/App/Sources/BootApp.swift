//
//  BootApp.swift
//  AppStarter
//
//  Created by hocgin on 2024/5/25.
//

import CoreData
import SheetKit
import SwiftHit
import SwiftUI

@main
struct BootApp: App {
    @StateObject private var globalState = GlobalState.shared

    var body: some Scene {
        WindowGroup {
            let _ = Log.core.info("theme = \(UserDefaults.standard.theme)")
            BootView()
                .environmentObject(globalState)
                .environment(\.managedObjectContext, globalState.CoreData.viewContext)
                .preferredColorScheme(UserDefaults.standard.theme.colorScheme)
                .onAppear {
                    Task {
                        await globalState.Api.fetchWeatherMock()
                    }
                }
        }
    }

    init() {
//        print(SwiftHit.text)
    }
}
