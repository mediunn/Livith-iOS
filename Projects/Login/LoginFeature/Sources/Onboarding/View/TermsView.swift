//
//  TermsView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct TermsView: View {
    @StateObject private var store = TermsStore()
    @EnvironmentObject private var router: LoginRouter
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                navigationBar
                    .padding(.top, 20)
                
                stepIndicator
                    .padding(.top, 20)
                
                title
                    .padding(.top, 32)
                
                allAgreeButton
                    .padding(.top, 20)
                
                termsSection
                    .padding([.top, .leading], 20)
                
                Spacer()
                
                nextButton
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - UIComponents

private extension TermsView {
    var navigationBar: some View {
        HStack {
            Button {
                router.pop()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .foregroundColor(.livithColor(.white100))
            }
            
            Text(Literals.navigationTitle)
                .notosans(.body1Semibold)
                .foregroundColor(.livithColor(.white100))
            
            Spacer()
        }
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
        HStack(spacing: 16) {
            Button {
                store.send(.toggleAllTermsAgreement)
            } label: {
                Image.livithIcon((store.state.isTermsAgreed && store.state.isMarketingAgreed) ? .checkboxFillEnabled : .checkboxFillDefault)
            }
            
            Text(Literals.allAgreeText)
                .notosans(.body2Medium)
                .foregroundColor(.livithColor(.white100))
            
            Spacer()
        }
        .padding(20)
        .background(Color.livithColor(.black80))
        .cornerRadius(12)
    }
    
    var termsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            termRow
            
            marketingRow
        }
    }
    
    var termRow: some View {
        HStack(spacing: 4) {
            Button {
                store.send(.toggleTermsAgreement)
            } label: {
                Image.livithIcon(store.state.isTermsAgreed ? .checkboxLineEnabled : .checkboxLineDefault)
            }
            
            Text(Literals.termsAgreementText)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
            
            Text(Literals.requiredText)
                .notosans(.caption1Regular)
                .foregroundStyle(Color.livithColor(.black50))
            
            Spacer()
            
            Button {
                // TODO: 약관 URL 웹뷰 시트로 열기
                guard let url = URL(string: Literals.termsURLString) else { return }
                openURL(url)
            } label: {
                Text(Literals.moreButtonText)
                    .notosans(.caption2Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.trailing, 4)
            }
        }
    }
    
    var marketingRow: some View {
        HStack(spacing: 4) {
            Button {
                store.send(.toggleMarketingAgreement)
            } label: {
                Image.livithIcon(store.state.isMarketingAgreed ? .checkboxLineEnabled : .checkboxLineDefault)
            }
            
            Text(Literals.marketingAgreementText)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }
    
    var nextButton: some View {
        Button {
            router.push(.nickname(store.state.isMarketingAgreed))
        } label: {
            Text(Literals.nextButtonText)
                .notosans(.body2Medium)
                .foregroundColor(store.state.isTermsAgreed ? Color.livithColor(.black100) : Color.livithColor(.black50))
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(store.state.isTermsAgreed ? Color.livithColor(.yellow30) : Color.livithColor(.black80))
                .cornerRadius(8)
        }
        .disabled(!store.state.isTermsAgreed)
    }
}

// MARK: - Literals

private extension TermsView {
    enum Literals {
        static let navigationTitle = "회원가입"
        static let title = "서비스 이용을 위해\n약관 동의가 필요해요"
        static let allAgreeText = "약관 모두 동의"
        static let termsAgreementText = "이용약관 동의"
        static let requiredText = "필수"
        static let moreButtonText = "더보기 >"
        static let marketingAgreementText = "마케팅 활용 / 광고성 정보 수신 동의"
        static let nextButtonText = "다음"
        static let termsURLString = "https://youz2me.notion.site/Livith-v-25-04-13-1d402dd0e5fc80eaacd9d3dfdc7d0aa0?pvs=4"
    }
}
