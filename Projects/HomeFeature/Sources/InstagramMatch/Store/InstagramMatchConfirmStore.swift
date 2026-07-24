//
//  InstagramMatchConfirmStore.swift
//  HomeFeature
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain

// MARK: - State

struct InstagramMatchConfirmState {
    var matchedConcertList: [Concert] = []
    var selectedConcertID: Int?
    var isExtracting: Bool = true
    var isRegistering: Bool = false
    var isCancelModalPresented: Bool = false
    var shouldNavigateToHome: Bool = false
    var shouldNavigateToSearch: Bool = false
    var successMessage: String = ""
    var errorMessage: String = ""

    var isCTAEnabled: Bool {
        selectedConcertID != nil
    }
}

// MARK: - Intent

enum InstagramMatchConfirmIntent {
    case selectConcert(Int)
    case register
    case cancelTapped
    case confirmCancel
    case dismissCancelModal
    case clearErrorMessage
    case clearSuccessMessage
    case _fetchMatchResult(Result<[Concert], Error>)
    case _registerResult(concert: Concert, Result<Void, Error>)
}

// MARK: - Store

@MainActor
final class InstagramMatchConfirmStore: ObservableObject {

    // MARK: - Properties

    @Published private(set) var state: InstagramMatchConfirmState

    @Injected private var concertMatchingRepository: ConcertMatchingRepository
    @Injected private var userRepository: UserRepository

    private let sourceURL: URL
    private var fetchMatchTask: Task<Void, Never>?

    // MARK: - Initializer

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.state = InstagramMatchConfirmState()

        performFetchMatchedConcertList()
    }

    deinit {
        fetchMatchTask?.cancel()
    }

    // MARK: - Public Interface

    func send(_ intent: InstagramMatchConfirmIntent) {
        switch intent {
        case .selectConcert(let concertID):
            guard !state.isExtracting else { return }

            state.selectedConcertID = state.selectedConcertID == concertID ? nil : concertID
        case .register:
            guard state.isCTAEnabled, !state.isRegistering else { return }
            guard let concert = selectedConcert() else { return }

            state.isRegistering = true
            state.errorMessage = ""
            state.successMessage = ""
            performRegister(concert: concert)
        case .cancelTapped:
            guard state.isCTAEnabled else {
                state.shouldNavigateToHome = true
                return
            }

            state.isCancelModalPresented = true
        case .confirmCancel:
            state.isCancelModalPresented = false
            state.shouldNavigateToHome = true
        case .dismissCancelModal:
            state.isCancelModalPresented = false
        case .clearErrorMessage:
            state.errorMessage = ""
        case .clearSuccessMessage:
            state.successMessage = ""
        case ._fetchMatchResult(let result):
            state.isExtracting = false
            switch result {
            case .success(let concertList):
                guard !concertList.isEmpty else {
                    state.shouldNavigateToSearch = true
                    return
                }

                state.matchedConcertList = Array(concertList.prefix(Constants.maxMatchedConcertCount))
            case .failure:
                state.shouldNavigateToSearch = true
            }
        case ._registerResult(let concert, let result):
            state.isRegistering = false
            switch result {
            case .success:
                state.successMessage = Constants.successMessage(for: concert)
                state.shouldNavigateToHome = true
            case .failure:
                state.errorMessage = Constants.registerFailureMessage
            }
        }
    }
}

// MARK: - Helpers

private extension InstagramMatchConfirmStore {
    func performFetchMatchedConcertList() {
        let repository = concertMatchingRepository
        let sourceURL = sourceURL

        fetchMatchTask = Task { [weak self] in
            do {
                let concertList = try await repository.fetchMatchedConcertList(sourceURL: sourceURL)
                self?.send(._fetchMatchResult(.success(concertList)))
            } catch {
                self?.send(._fetchMatchResult(.failure(error)))
            }
        }
    }

    func performRegister(concert: Concert) {
        let repository = userRepository

        Task {
            do {
                let isAlreadyInterested = try await repository.checkInterestedConcert(id: concert.id)
                if !isAlreadyInterested {
                    try await repository.updateInterestedConcert(concert.id)
                }
                send(._registerResult(concert: concert, .success(())))
            } catch {
                send(._registerResult(concert: concert, .failure(error)))
            }
        }
    }

    func selectedConcert() -> Concert? {
        guard let selectedConcertID = state.selectedConcertID else { return nil }

        return state.matchedConcertList.first { $0.id == selectedConcertID }
    }
}

private extension InstagramMatchConfirmStore {
    enum Constants {
        static let maxMatchedConcertCount = 3
        static let successMessageTitleLimit = 20
        static let registerFailureMessage = "관심 콘서트 등록에 실패했어요\n다시 시도해주세요"

        static func successMessage(for concert: Concert) -> String {
            let title = ConcertDisplayHelper.title(for: concert)
            let truncatedTitle = title.count > successMessageTitleLimit
                ? "\(title.prefix(successMessageTitleLimit)).."
                : title

            return "\(truncatedTitle) 콘서트가\n관심 콘서트와 일정에 자동 등록되었어요"
        }
    }
}
