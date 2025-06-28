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
        Button("Error View") {
            withPathError {
                throw AppError.unknown
            }
        }
        .buttonStyle(.bordered)

        Button("Toast") {
            withToastError {
                throw AppError.unknown
            }
        }
        .buttonStyle(.bordered)
    }
}
