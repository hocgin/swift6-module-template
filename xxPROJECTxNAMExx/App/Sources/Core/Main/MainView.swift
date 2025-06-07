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
            NavigationLink(state: Boot.Path.State.main) {
                Text("main")
            }
            NavigationLink(state: Boot.Path.State.todos(.init())) {
                Text("todos")
            }
            NavigationLink(state: Boot.Path.State.qwebclient(.init())) {
                Text("qwebclient")
            }
            NavigationLink(state: Boot.Path.State.tpl(.init())) {
                Text("tpl")
            }
            NavigationLink(state: Boot.Path.State.qdatabase(.init())) {
                Text("qdatabase")
            }
            NavigationLink(state: Boot.Path.State.pageroute(.init())) {
                Text("pageroute")
            }
        }
    }
}
