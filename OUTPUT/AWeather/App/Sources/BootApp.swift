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
                        await loadDistrictData()
                        await globalState.Api.fetchWeatherMock()
                    }
                }
        }
    }

    func loadDistrictData() async {
        /// 1. 检查数据库最后一条数据
        if let lastDistrict = globalState.CoreData.lastDistrict() {
            Log.core.debug("本地已有地理位置数据，不进行同步。数据同步时间 = \(lastDistrict.createdAt)")
            return
        }

        /// 2. 拉取数据
        let district = await globalState.Api.getDistrictData()
        Log.network.debug("同步地理位置数量 size = \(district.count)")

        if district.isEmpty {
            Log.network.warning("拉取地理位置数据失败 size = 0")
            return
        }

        /// 3. 删除数据 & 新增数据
        globalState.CoreData.importDistrictData(district)
    }

    init() {
//        print(SwiftHit.text)
    }
}
