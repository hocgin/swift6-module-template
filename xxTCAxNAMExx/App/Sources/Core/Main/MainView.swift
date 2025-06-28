//
//  MainView.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import SwiftUI
import SwiftUIError

struct MainView: View {
    var body: some View {
        Text("MainView")
            .onTapGesture {
                withPathError {
                    throw AppError.unknown
                }
            }
    }
}
