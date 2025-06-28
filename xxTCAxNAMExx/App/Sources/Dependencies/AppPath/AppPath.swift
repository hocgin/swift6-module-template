//
//  GlobalPath.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import ComposableArchitecture
import SwiftUIError

// @Reducer
@CasePathable
@dynamicMemberLookup
enum AppPath: Hashable {
    case main
    case dev
    case error(AppError)
}

// extension AppPath.State: Equatable {}

extension SharedKey where Self == InMemoryKey<[AppPath]>.Default {
    static var path: Self {
        Self[
            .inMemory("path"),
            default: []
        ]
    }
}
