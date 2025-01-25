//
//  BootView.swift
//  AppStarter
//
//  Created by hocgin on 2024/5/25.
//

import CoreData
import SwiftHit
import SwiftUI
import Voyager

enum AppRoute: Route {
    /// 主页
    case main
    /// 天气主页
    case weather
    /// 添加位置
    case addLocation
    /// 设置页面
    case setting
    /// 控制台页面
    case console
    /// 日期详情
    case dayDetail(date: Date = .init(), chart: DayDetailView.Chart = .rainfall)
    /// 空气质量详情
    case aqiDetail
    /// 日出日落详情
    case sunDetail
    /// 恶劣天气预警详情
    case alert
}

struct BootView: View {
    @EnvironmentObject private var appState: GlobalState
    @StateObject var router = Router<AppRoute>(root: .main)

    var body: some View {
        NavVoyagerView(router: router) { route in
            switch route {
            case .main: MainView()
            case .main: AddLocationView(latitude: 0, longitude: 0)
//            case .weather: MainView()
            case .setting: SettingView()
            case .addLocation: AddLocationView(latitude: 0, longitude: 0)
            case .dayDetail(let date, let chart): DayDetailView(date: date, chart: chart)
            case .aqiDetail: AQIDetailView()
            case .sunDetail: SunDetailView()
            case .alert: AlertView()
            default: Text("default \(route.id)")
            }
        }.onTapGesture {
            let _ = appState.locationKit.requestAuthorization()
            let _ = appState.locationKit.getCurrentLocation()
        }
    }
}

#Preview {
    BootView()
        .environmentObject(GlobalState.shared)
        .environment(\.managedObjectContext, GlobalState.shared.CoreData.viewContext)
}
