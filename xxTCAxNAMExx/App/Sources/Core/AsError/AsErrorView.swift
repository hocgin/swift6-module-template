//
//  ErrorView.swift
//  App
//
//  Created by hocgin on 2025/6/28.
//
import ComposableArchitecture
import SwiftLogKit
import SwiftUI
import SwiftUIErrorUI
import SwiftUIMessage

@Reducer
struct AsError {
    @ObservableState
    struct State: Equatable {
        var error: AppError
    }

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

struct AsErrorView: View {
    @Bindable var store: StoreOf<AsError>

    @State private var isLoading = false
    @State var fileContent: [String]?

    var attachment: MailComposeView.AttachmentData {
        .init(
            attachment: (fileContent?.joined(separator: "\n") ?? "").data(using: .utf8)!,
            mimeType: "text/plain",
            fileName: "app.log"
        )
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            else {
                AppErrorView(store.error, mailView: { AnyView(mailView) }) { withHome() }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadData()
        }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        fileContent = Logger.getLogs()
    }

    @ViewBuilder
    var mailView: some View {
        MailComposeView(.init(
            toRecipients: [
                "test@hocg.in"
            ],
            body: "Test"
        ))
        .withAttachments(attachment)
        .ignoresSafeArea()
    }
}
