//
//  TermsView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

struct TermsView: View {
    @StateObject private var store = TermsStore()
    @Environment(\.loginCoordinator) private var coordinator
    @Environment(\.openURL) private var openURL
    @State private var showSafari = false
    @State private var safariURL: URL?
    
    private let tempUser: TempUser
    
    init(tempUser: TempUser) {
        self.tempUser = tempUser
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar

            stepIndicator
                .padding(.top, 10)
                .padding(.horizontal, 16)

            title
                .padding(.top, 32)
                .padding(.horizontal, 16)

            allAgreeButton
                .padding(.top, 20)
                .padding(.horizontal, 16)

            termsSection
                .padding(.top, 20)
                .padding(.horizontal, 20)

            Spacer()

            nextButton
                .padding(.bottom, 50)
                .padding(.horizontal, 16)
        }
        .background(Color.livithColor(.black100))
        .ignoresSafeArea(.all, edges: .bottom)
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
    }
}

// MARK: - UIComponents

private extension TermsView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(title: Literals.navigationTitle, onBack: { coordinator?.pop() })
        )
    }
    
    var stepIndicator: some View {
        StepIndicatorView(currentStep: 1, totalSteps: 4)
    }
    
    var title: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text(Literals.subtitle)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }
    
    var allAgreeButton: some View {
        Button {
            store.send(.toggleAllTermsAgreement)
        } label: {
            HStack(spacing: 16) {
                Image.livithIcon(isAllAgreed ? .checkboxFillEnabled : .checkboxFillDefault)
                
                Text(Literals.allAgreeText)
                    .notosans(.body2Medium)
                    .foregroundColor(.livithColor(.white100))
                
                Spacer()
            }
            .padding(20)
            .background(Color.livithColor(.black80))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    var termsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            termRow

            privacyRow

            marketingRow
        }
    }

    var termRow: some View {
        CheckboxRow(
            Literals.termsAgreementText,
            isRequired: true,
            isChecked: isTermsAgreed,
            action: { store.send(.toggleTermsAgreement) },
            trailingView: AnyView(moreButton(urlString: Literals.termsURLString))
        )
    }

    var privacyRow: some View {
        CheckboxRow(
            Literals.privacyAgreementText,
            isRequired: true,
            isChecked: isPrivacyAgreed,
            action: { store.send(.togglePrivacyAgreement) },
            trailingView: AnyView(moreButton(urlString: Literals.privacyURLString))
        )
    }

    var marketingRow: some View {
        CheckboxRow(
            Literals.marketingAgreementText,
            isChecked: isMarketingAgreed,
            action: { store.send(.toggleMarketingAgreement) },
            trailingView: AnyView(moreButton(urlString: Literals.marketingURLString))
        )
    }
    
    var nextButton: some View {
        LivithButton(Literals.nextButtonText, variant: .primary) {
            coordinator?.push(to: .nickname(.start(tempUser: tempUser, isMarketingAgreed: isMarketingAgreed)))
        }
        .disabled(!canProceed)
    }
    
    func moreButton(urlString: String) -> some View {
        Button {
            safariURL = URL(string: urlString)
            showSafari = true
        } label: {
            Text(Literals.moreButtonText)
                .notosans(.caption2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }
}

// MARK: - Helpers

private extension TermsView {
    var isTermsAgreed: Bool { store.state.isTermsAgreed }
    var isPrivacyAgreed: Bool { store.state.isPrivacyAgreed }
    var isMarketingAgreed: Bool { store.state.isMarketingAgreed }
    var isAllAgreed: Bool { isTermsAgreed && isPrivacyAgreed && isMarketingAgreed }
    var canProceed: Bool { isTermsAgreed && isPrivacyAgreed }
}

// MARK: - Literals

private extension TermsView {
    enum Literals {
        static let navigationTitle = "회원가입"
        static let title = "서비스 이용을 위해\n약관 동의가 필요해요"
        static let subtitle = "서비스 이용에 필요한 알림이 발송될 예정이에요"
        static let allAgreeText = "약관 모두 동의"
        static let termsAgreementText = "이용약관 동의"
        static let privacyAgreementText = "개인정보 이용 동의"
        static let marketingAgreementText = "마케팅 활용 / 광고성 정보 수신 동의"
        static let moreButtonText = "더보기 >"
        static let nextButtonText = "다음"
        static let termsURLString = "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0"
        static let privacyURLString = "https://youz2me.notion.site/v-26-02-03-2fb02dd0e5fc806ca182ecaf18099979"
        static let marketingURLString = "https://youz2me.notion.site/v-26-02-03-2fb02dd0e5fc80af9708cf5e39f44f77"
    }
}
