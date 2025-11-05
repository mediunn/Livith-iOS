//
//  TermsView.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import DesignSystem

struct TermsView: View {
    @StateObject private var store = OnboardingStore()
    
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
            Button(action: {
                
                // TODO: 라우터에게 다시 로그인 화면으로 돌아가도록 전달
                
            }) {
                Image.livithIcon(.backLineDefault)
                    .foregroundColor(.livithColor(.white100))
            }
            
            Text("회원가입")
                .notosans(.body1Semibold)
                .foregroundColor(.livithColor(.white100))
            
            Spacer()
        }
    }
    
    var stepIndicator: some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(Color.livithColor(.yellow60))
                .frame(height: 4)
            
            Capsule()
                .fill(Color.livithColor(.black50))
                .frame(height: 4)
        }
    }
    
    var title: some View {
        Text("서비스 이용을 위해\n약관 동의가 필요해요")
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.white100))
    }
    
    var allAgreeButton: some View {
        HStack(spacing: 16) {
            Button {
                store.send(.toggleAllTermsAgreement)
            } label: {
                Image.livithIcon(store.state.isAllAgreed ? .checkboxFillEnabled : .checkboxFillDefault)
            }
            
            Text("약관 모두 동의")
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
            
            Text("이용약관 동의")
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
            
            Text("필수")
                .notosans(.caption1Regular)
                .foregroundStyle(Color.livithColor(.black50))
            
            Spacer()
            
            Button {
                
                // TODO: 라우터에게 전달
                
            } label: {
                Text("더보기 >")
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
            
            Text("마케팅 활용 / 광고성 정보 수신 동의")
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }
    
    var nextButton: some View {
        Button {
            
            // TODO: 라우터에게 닉네임 설정 화면으로 이동
            
        } label: {
            Text("다음")
                .notosans(.body2Medium)
                .foregroundColor(store.state.isNextButtonEnabled ? Color.livithColor(.black100) : Color.livithColor(.black50))
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(store.state.isNextButtonEnabled ? Color.livithColor(.yellow30) : Color.livithColor(.black80))
                .cornerRadius(12)
        }
        .disabled(!store.state.isNextButtonEnabled)
    }
}

#Preview {
    TermsView()
}
