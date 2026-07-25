//
//  ConcertRequestStore.swift
//  ShareFeature
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - State

struct ConcertRequestState {
    var isSubmitting: Bool = false
    var didSubmitSucceed: Bool = false
    var showFailureToast: Bool = false
}

// MARK: - Intent

enum ConcertRequestIntent {
    case submit(title: String, url: String?, shouldAutoRegister: Bool, requestContent: String?)
    case onFailureToastDisappear
    case _submitResult(Result<Void, Error>)
}

// MARK: - Store

final class ConcertRequestStore: ObservableObject {
    @Published private(set) var state = ConcertRequestState()

    @Injected private var concertRepository: ConcertRepository

    @MainActor
    func send(_ intent: ConcertRequestIntent) {
        switch intent {
        case .submit(let title, let url, let shouldAutoRegister, let requestContent):
            guard !state.isSubmitting else { return }
            state.isSubmitting = true
            state.showFailureToast = false
            performSubmit(
                title: title,
                url: url,
                shouldAutoRegister: shouldAutoRegister,
                requestContent: requestContent
            )

        case .onFailureToastDisappear:
            state.showFailureToast = false

        case ._submitResult(let result):
            state.isSubmitting = false
            switch result {
            case .success:
                state.didSubmitSucceed = true
            case .failure:
                state.showFailureToast = true
            }
        }
    }
}

// MARK: - Helper

private extension ConcertRequestStore {
    func performSubmit(
        title: String,
        url: String?,
        shouldAutoRegister: Bool,
        requestContent: String?
    ) {
        Task {
            do {
                try await concertRepository.requestConcert(
                    title: title,
                    url: url,
                    shouldAutoRegister: shouldAutoRegister,
                    requestContent: requestContent
                )
                await MainActor.run {
                    send(._submitResult(.success(())))
                }
            } catch {
                await MainActor.run {
                    send(._submitResult(.failure(error)))
                }
            }
        }
    }
}
