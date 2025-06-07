//
//  DatabaseView.swift
//  App
//
//  Created by hocgin on 2025/6/7.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct QDatabase {
    @ObservableState
    struct State {}

    enum Action {
        case onAppear
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let _ = state
                debugPrint("加载项 新数据..")
                return .none
            default:
                return .none
            }
        }
    }
}

struct QDatabaseView: View {
    var body: some View {
        Text("")
            .onAppear()
    }
}
