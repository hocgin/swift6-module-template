//
//  Guide+.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import SwiftGuideKit
import SwiftUI

extension BootView {
    func askAppGuide() -> some View {
        self.askGuide(.init(
            forceShow: true,
            items: [
                .init(title: "Welcome to PlayStation", subtitle: "Your journey starts here",
                      content: { _ in
                          MorphingSymbolView(
                              symbol: "playstation.logo",
                              config: .init(
                                  font: .system(size: 150, weight: .bold),
                                  frame: .init(width: 250, height: 200),
                                  radius: 30,
                                  foregroundColor: .white,
                                  keyFrameDuration: 0.4,
                                  symbolAnimation: .smooth(duration: 0.5, extraBounce: 0)
                              )
                          )
                      },
                      background: LinearGradient(
                          gradient: Gradient(colors: [.purple, .red]),
                          startPoint: .top,
                          endPoint: .bottom
                      )),
                .init(
                    title: "DualSense wireless controller", subtitle: "Discover a deeper gaming experience\nwith the DualSense controller",
                    content: { _ in
                        MorphingSymbolView(
                            symbol: "gamecontroller.fill",
                            config: .init(
                                font: .system(size: 150, weight: .bold),
                                frame: .init(width: 250, height: 200),
                                radius: 30,
                                foregroundColor: .white,
                                keyFrameDuration: 0.4,
                                symbolAnimation: .smooth(duration: 0.5, extraBounce: 0)
                            )
                        )
                    },
                    background: LinearGradient(
                        gradient: Gradient(colors: [.purple, .blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                ),
                .init(
                    title: "PlayStation Remote Play", subtitle: "Stream your PS5 to Mac or\nApple devices.",
                    content: { _ in
                        Text("好东西").foregroundStyle(.white)
                    },
                    background: LinearGradient(
                        gradient: Gradient(colors: [.yellow, .green]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            ]
        ))
    }
}
