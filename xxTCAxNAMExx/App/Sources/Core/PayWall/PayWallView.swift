//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI
import SwiftUIStoreUI

@Reducer
struct PayWall {
    @ObservableState
    struct State: Equatable {}

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct PayWallView: View {
    @Bindable var store: StoreOf<PayWall>

    var body: some View {
        VStack {
            SwiftUIStoreUI.PayWallView()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct PayWallSheetView: View {
    @Bindable var store: StoreOf<PayWall>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.01)
                .background(.thinMaterial)
                .ignoresSafeArea()
            PayWallView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .top) {
                    HStack {
                        Spacer(minLength: .zero)
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.gray)
                                .imageScale(.large)
                                .backgroundStyle(.background.opacity(0.2))
                        }
                    }
                    .padding(.trailing)
                    .padding(.top)
                }
        }
        .presentationBackground(.clear)
        .preferredColorScheme(.dark)
    }
}

/// =======================================================

extension PayWall.State {
    static let mock: Self = .init()
}

#Preview {
    PayWallView(
        store: Store(initialState: .mock, reducer: PayWall.init)
    )
    .environmentObject(BootApp.storeContext)
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            PayWallSheetView(
                store: Store(initialState: .mock, reducer: PayWall.init)
            )
        }
        .environmentObject(BootApp.storeContext)
}
