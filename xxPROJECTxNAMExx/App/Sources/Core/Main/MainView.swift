//
//  MainView.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import ExtensionHit
import SwiftUI

struct MainView: View {
    var body: some View {
        List {
            NavigationLink(state: AppRoute.State.main) {
                Text("main")
            }
            NavigationLink(state: AppRoute.State.todos(.init())) {
                Text("todos")
            }
            NavigationLink(state: AppRoute.State.qwebclient(.init())) {
                Text("qwebclient")
            }
            NavigationLink(state: AppRoute.State.tpl(.init())) {
                Text("tpl")
            }
            NavigationLink(state: AppRoute.State.qdatabase(.init())) {
                Text("qdatabase")
            }
            NavigationLink(state: AppRoute.State.pageroute(.init())) {
                Text("pageroute")
            }
            NavigationLink(state: AppRoute.State.qlocation(.init())) {
                Text("qlocation")
            }
            NavigationLink(state: AppRoute.State.qscene(.init())) {
                Text("scene")
            }
        }
    }
}
