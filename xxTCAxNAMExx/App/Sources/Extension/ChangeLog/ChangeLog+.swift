//
//  ChangeLog+.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import SwiftChangeKit
import SwiftUI

extension View {
    func askAppChangeLog(_ action: @escaping () -> Void) -> some View {
        self.askChangeLog(.init(
            publishAt: .now,
            version: "1.6",
            description: "优化了多项功能来提升你的使用体验，快来试试吧!",
            list: [
                .feature("新增锁屏 **小组件**"),
                .feature("新增像素天气主题"),
                .fixbug("优化界面卡顿，提升功能流畅度"),
                .fixbug("修复天气通知丢失问题"),
            ],
            discountDate: Date.now.addingTimeInterval(60 * 10),
            proAction: {
                debugPrint("前往购买")
                action()
            }
        ))
    }
}
