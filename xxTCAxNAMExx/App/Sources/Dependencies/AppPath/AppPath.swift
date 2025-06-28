//
//  GlobalPath.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import ComposableArchitecture

@Reducer
enum AppPath {
    case main
}

extension AppPath.State: Equatable {}

extension SharedKey where Self == InMemoryKey<StackState<AppPath.State>>.Default {
    static var path: Self {
        Self[
            .inMemory("path"),
            default: StackState([])
        ]
    }
}
