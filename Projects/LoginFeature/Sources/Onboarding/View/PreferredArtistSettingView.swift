//
//  PreferredArtistSettingView.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem
import PreferenceFeature

struct PreferredArtistSettingView: View {
    @Environment(\.loginCoordinator) private var coordinator
    @StateObject private var store: SignupStore
    
    @State private var isSignupFailureModalPresented: Bool = false
    @State private var signupFailureMessage: String = ""
    
    private let builder: SignupBuilder
    
    init(builder: SignupBuilder) {
        self.builder = builder
        self._store = StateObject(wrappedValue: SignupStore(builder: builder))
    }
    
    var body: some View {
        ArtistEditView(
            config: .onboarding(),
            isSubmitting: store.state.isSubmitting
        ) {
            coordinator?.pop()
        } onSkip: {
            store.send(.submit([]))
        } onSubmit: { selectedArtistList in
            store.send(.submit(selectedArtistList))
        }
        .onChange(of: store.state.result) { _, newValue in
            handleSignupResult(newValue)
        }
        .crossDissolve(isPresented: $isSignupFailureModalPresented, dismissOnTapOutside: false) {
            LivithModal(
                type: .error(title: "오류가 발생했어요!", message: signupFailureMessage),
                confirmTitle: "로그인으로 돌아가기",
                onConfirm: {
                    isSignupFailureModalPresented = false
                    coordinator?.popToRoot()
                }
            )
        }
    }
}

// MARK: - Helpers

private extension PreferredArtistSettingView {
    func handleSignupResult(_ result: SignupState.Result) {
        switch result {
        case .idle:
            break
        case .success:
            coordinator?.completeSignup(with: builder.nickname)
        case .failure(let message):
            signupFailureMessage = message
            isSignupFailureModalPresented = true
        }
    }
}
