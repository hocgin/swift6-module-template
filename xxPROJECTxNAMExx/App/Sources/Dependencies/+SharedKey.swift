//
//  Shared.swift
//  App
//
//  Created by hocgin on 2025/6/8.
//

import ComposableArchitecture

// extension SharedKey where Self == InMemoryKey<StackState<AppRoute.State>> {
//    static var route: Self {
//        inMemory("route")
//    }
// }

extension SharedKey where Self == InMemoryKey<StackState<AppRoute.State>>.Default {
    static var route: Self {
        Self[
            .inMemory("route"),
            default: StackState([])
        ]
    }
}

extension SharedKey where Self == InMemoryKey<IdentifiedArrayOf<QShared.State>>.Default {
    static var sharedsItems: Self {
        Self[
            .inMemory("QShareds.items"),
            default: IdentifiedArrayOf<QShared.State>([])
        ]
    }
}
