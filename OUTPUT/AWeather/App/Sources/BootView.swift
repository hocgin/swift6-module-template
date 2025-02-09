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
    /// 添加位置
    case addLocation
    /// 设置页面
    case setting
    /// 控制台页面
    case control
    case beta
    /// 日期详情
    case dayDetail(date: Date = .init(), chart: DayDetailView.Chart = .rainfall)
    /// 天气主页
    case weather(latitude: Decimal? = nil, longitude: Decimal? = nil)
    /// 天气预览
    case preview(latitude: Decimal, longitude: Decimal)
    /// 空气质量详情
    case aqiDetail
    /// 日出日落详情
    case sunDetail
    /// 恶劣天气预警详情
    case alert
    /// 会员订阅
    case subscription
}

struct BootView: View {
    @EnvironmentObject private var globalState: GlobalState
    @StateObject var router = Router<AppRoute>(root: .main)

    var body: some View {
        NavVoyagerView(router: router) { route in
            let _ = Log.ui.debug("正在进入 route = \(route)")
            switch route {
                case .main: MainView()
                case .setting: SettingView()
                case .weather(let latitude, let longitude): MainView(latitude: latitude, longitude: longitude)
                case .preview(let latitude, let longitude): LocationPreviewView(latitude: latitude, longitude: longitude)
                case .addLocation: AddLocationView()
                case .dayDetail(let date, let chart): DayDetailView(date: date, chart: chart)
                case .aqiDetail: AQIDetailView()
                case .sunDetail: SunDetailView()
                case .beta: BetaView()
                case .alert: AlertView()
                case .subscription: AlertView()
                default: Text("default \(route.id)")
            }
        }
        .onAppear {
            let _ = globalState.locationKit.requestAuthorization()
            let _ = globalState.locationKit.getCurrentLocation()
        }
    }
}

#Preview {
    BootView()
        .environmentObject(GlobalState.shared)
        .environment(\.managedObjectContext, GlobalState.shared.CoreData.viewContext)
}
