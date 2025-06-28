//
//  Error+Toast.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//

import ComposableArchitecture
import SwiftLogKit
import SwiftUIError
import SwiftUIToast

extension Toast {}

func withToastError(_ action: @escaping () throws -> Void) {
    do {
        try action()
    } catch {
        logger.error("\(error)")
        Toast.error(error)
    }
}

func withToastError(_ action: @escaping () async throws -> Void) async {
    do {
        try await action()
    } catch {
        logger.error("\(error.localizedDescription)")
        Toast.error(error)
    }
}
