//
//  Error+.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//

import ComposableArchitecture
import SwiftLogKit
import SwiftUIError
import SwiftUIToast

extension AppError {
    /// 扩展错误
}

func withPathError(_ action: @escaping () throws -> Void) {
    do {
        try action()
    } catch {
        withPath(.error(AppError.wrap(error)))
    }
}

func withPathError(_ action: @escaping () async throws -> Void) async {
    do {
        try await action()
    } catch {
        withPath(.error(AppError.wrap(error)))
    }
}

func withPath(_ apath: AppPath) {
    @Shared(.path) var path

//    _ = $path.withLock { $0.removeLast() }
    $path.withLock { $0 = [apath] }
}

func withHome() {
    @Shared(.path) var path
    $path.withLock { $0 = [] }
}

func withAddPath(_ apath: AppPath) {
    @Shared(.path) var path
    $path.withLock { $0.append(apath) }
}
