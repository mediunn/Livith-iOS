//
//  ConcertRequestStore.swift
//  ShareFeature
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Observation

import Domain

@MainActor
@Observable
final class ConcertRequestViewModel {
    enum Submission: Equatable {
        case idle
        case submitting
        case succeeded
        case failed
    }

    var concertName: String
    var urlText: String
    var additionalNote: String
    private(set) var submission: Submission = .idle

    private let repository: any ConcertRequestRepository

    init(
        repository: any ConcertRequestRepository,
        concertName: String = "",
        urlText: String = "",
        additionalNote: String = ""
    ) {
        self.repository = repository
        self.concertName = concertName
        self.urlText = urlText
        self.additionalNote = additionalNote
    }

    var hasInput: Bool {
        [concertName, urlText, additionalNote].contains {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var isSubmitEnabled: Bool {
        ConcertRequest.isTitleValid(concertName)
    }

    func submit(shouldAutoRegister: Bool) async {
        guard submission != .submitting, submission != .succeeded else { return }
        submission = .submitting

        do {
            let request = try ConcertRequest(
                title: concertName,
                url: urlText,
                shouldAutoRegister: shouldAutoRegister,
                requestContent: additionalNote
            )
            try await repository.requestConcert(request)
            submission = .succeeded
        } catch {
            submission = .failed
        }
    }

    func dismissFailure() {
        guard submission == .failed else { return }
        submission = .idle
    }
}
