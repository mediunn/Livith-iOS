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
    @State private var isDiscardChangesModalPresented: Bool = false
    
    private let builder: SignupBuilder
    
    init(builder: SignupBuilder) {
        self.builder = builder
        self._store = StateObject(wrappedValue: SignupStore(builder: builder))
    }
    
    var body: some View {
        ArtistEditView(
            config: .onboarding(),
            isSubmitting: store.state.isSubmitting
        ) { isModified in
            if isModified {
                isDiscardChangesModalPresented = true
            } else {
                coordinator?.pop()
            }
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
                type: .error(title: Literals.signupFailureModalTitle, message: store.state.errorMessage),
                confirmTitle: Literals.signupFailureModalConfirmTitle,
                onConfirm: {
                    isSignupFailureModalPresented = false
                    coordinator?.popToRoot()
                }
            )
        }
        .crossDissolve(isPresented: $isDiscardChangesModalPresented, dismissOnTapOutside: false) {
            LivithDangerModal(
                message: Literals.discardChangesTitle,
                confirmTitle: Literals.discardChangesConfirmTitle,
                cancelTitle: Literals.discardChangesCancelTitle,
                type: .confirm(onConfirm: {
                    isDiscardChangesModalPresented = false
                    coordinator?.pop()
                }),
                onCancel: {
                    isDiscardChangesModalPresented = false
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
        case .failure:
            isSignupFailureModalPresented = true
        }
    }
}

// MARK: - Literals

private extension PreferredArtistSettingView {
    enum Literals {
        static let signupFailureModalTitle = "오류가 발생했어요!"
        static let signupFailureModalConfirmTitle = "로그인으로 돌아가기"
        static let discardChangesTitle = "선택된 아티스트나 장르가 해제돼요.\n이전 페이지로 돌아가시나요?"
        static let discardChangesConfirmTitle = "뒤로 갈게요"
        static let discardChangesCancelTitle = "잘못 눌렀어요"
    }
}
