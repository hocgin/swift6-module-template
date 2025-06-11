//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct QSheet {
    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)
        case sheet(QSheetSheet)
        case popover(QSheetPopover)
        case fullScreenCover(QSheetFullScreenCover)

        @CasePathable
        enum Alert {
            case confirmDeletion
            case continueWithoutRecording
            case openSettings
        }

        @CasePathable
        enum ConfirmationDialog {
            case dialog1
        }
    }

    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        @Presents var destination: Destination.State?
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case openSheet
        case openFullScreenCover
        case openAlert
        case openPopover
        case openDialog1
        case destination(PresentationAction<Destination.Action>)
        case loaded(String)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("加载项 新数据..")
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(nanoseconds: 6_000_000_000)
                    await send(.loaded(UUID().uuidString))
                }
            case .openSheet:
                state.destination = .sheet(QSheetSheet.State())
                return .none
            case .openPopover:
                state.destination = .popover(.init())
                return .none
            case .openFullScreenCover:
                state.destination = .fullScreenCover(.init())
                return .none
            case .openAlert:
                state.destination = .alert(.deleteExample)
                return .none
            case .openDialog1:
                state.destination = .confirmationDialog(.dialog1)
                return .none
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension QSheet.Destination.State: Equatable {}

struct QSheetView: View {
    @Bindable var store: StoreOf<QSheet>

    var body: some View {
        VStack {
            Text("Todo.\(store.id)")
            Text("\(store.isLoading ? "加载中" : "加载完成")")
            Button("OpenSheet") { store.send(.openSheet) }
            Button("OpenAlert") { store.send(.openAlert) }
            Button("OpenPopover") { store.send(.openPopover) }
            Button("openDialog1") { store.send(.openDialog1) }
            Button("openFullScreenCover") { store.send(.openFullScreenCover) }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .sheet(item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)) { store in
            QSheetSheetView(store: store)
        }
        .fullScreenCover(item: $store.scope(
            state: \.destination?.fullScreenCover,
            action: \.destination.fullScreenCover
        )) {
            QSheetFullScreenCoverView(store: $0)
        }
        .popover(item: $store.scope(
            state: \.destination?.popover,
            action: \.destination.popover
        )) { store in
            QSheetPopoverView(store: store)
        }
        .confirmationDialog(
            $store.scope(
                state: \.destination?.confirmationDialog,
                action: \.destination.confirmationDialog
            )
        )
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// Marker: - 弹窗内容 Alert
extension AlertState where Action == QSheet.Destination.Alert {
    static let deleteExample = Self {
        TextState("Delete?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeletion) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this meeting?")
    }

    static let speechRecognitionDenied = Self {
        TextState("Speech recognition denied")
    } actions: {
        ButtonState(action: .continueWithoutRecording) {
            TextState("Continue without recording")
        }
        ButtonState(action: .openSettings) {
            TextState("Open settings")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState(
            """
            You previously denied speech recognition and so your meeting will not be recorded. You can \
            enable speech recognition in settings, or you can continue without recording.
            """
        )
    }

    static let speechRecognitionRestricted = Self {
        TextState("Speech recognition restricted")
    } actions: {
        ButtonState(action: .continueWithoutRecording) {
            TextState("Continue without recording")
        }
        ButtonState(role: .cancel) {
            TextState("Cancel")
        }
    } message: {
        TextState(
            """
            Your device does not support speech recognition and so your meeting will not be recorded.
            """
        )
    }
}

/// MARKER: - 弹窗内容 Popover
extension ConfirmationDialogState where Action == QSheet.Destination.ConfirmationDialog {
    static let dialog1 = ConfirmationDialogState(title: {
        TextState("Dialog 1")
    })
}

/// =======================================================

extension QSheet.State {
    static let mock: Self = .init()
}

#Preview {
    QSheetView(
        store: Store(initialState: .mock) { QSheet() }
    )
}
