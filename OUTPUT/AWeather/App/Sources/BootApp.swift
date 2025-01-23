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

    func loadDistrictData() async {
        /// 1. 检查数据库是否有数据
        /// 2. 拉取数据
        /// 3. 删除数据
        /// 4. 新增数据

        let district = await globalState.Api.getDistrictData()
    }

    init() {
//        print(SwiftHit.text)
    }
}
