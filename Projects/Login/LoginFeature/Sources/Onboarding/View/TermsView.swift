//
//  TermsView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct TermsView: View {
    @StateObject private var store = TermsStore()
    @Environment(\.loginCoordinator) private var coordinator
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navigationBar

                stepIndicator
                    .padding(.top, 20)
                    .padding(.horizontal, 16)

                title
                    .padding(.top, 32)
                    .padding(.horizontal, 16)

                allAgreeButton
                    .padding(.top, 20)
                    .padding(.horizontal, 16)

                termsSection
                    .padding(.top, 20)
                    .padding(.leading, 36)

                Spacer()

                nextButton
                    .padding(.bottom, 50)
                    .padding(.horizontal, 16)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
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
        HStack(spacing: 4) {
            Capsule()
                .fill(Color.livithColor(.yellow30))
                .frame(height: 4)
            
            Capsule()
                .fill(Color.livithColor(.black80))
                .frame(height: 4)
        }
    }
    
    var title: some View {
        Text(Literals.title)
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.white100))
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
    }
    
    var termsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            termRow
            
            marketingRow
        }
    }
    
    var termRow: some View {
        CheckboxRow(
            Literals.termsAgreementText,
            isRequired: true,
            isChecked: isTermsAgreed,
            action: { store.send(.toggleTermsAgreement) },
            trailingView: AnyView(
                Button {
                    guard let url = URL(string: Literals.termsURLString) else { return }
                    coordinator?.present(to: .safari(url))
                } label: {
                    Text(Literals.moreButtonText)
                        .notosans(.caption2Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .padding(.trailing, 4)
                }
            )
        )
    }
    
    var marketingRow: some View {
        CheckboxRow(
            Literals.marketingAgreementText,
            isChecked: isMarketingAgreed,
            action: { store.send(.toggleMarketingAgreement) }
        )
    }
    
    
    
    var nextButton: some View {
        LivithButton(Literals.nextButtonText, variant: .primary) {
            coordinator?.push(to: .nickname(isMarketingAgreed))
        }
        .disabled(!canProceed)
    }
}

// MARK: - Helpers

private extension TermsView {
    var isTermsAgreed: Bool { store.state.isTermsAgreed }
    var isMarketingAgreed: Bool { store.state.isMarketingAgreed }
    var isAllAgreed: Bool { isTermsAgreed && isMarketingAgreed }
    var canProceed: Bool { isTermsAgreed }
}

// MARK: - Literals

private extension TermsView {
    enum Literals {
        static let navigationTitle = "회원가입"
        static let title = "서비스 이용을 위해\n약관 동의가 필요해요"
        static let allAgreeText = "약관 모두 동의"
        static let termsAgreementText = "이용약관 동의"
        static let moreButtonText = "더보기 >"
        static let marketingAgreementText = "마케팅 활용 / 광고성 정보 수신 동의"
        static let nextButtonText = "다음"
        static let termsURLString = "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0?pvs=4"
    }
}
