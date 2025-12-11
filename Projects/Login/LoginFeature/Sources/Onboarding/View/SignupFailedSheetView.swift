//
//  SignupFailedSheetView.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct SignupFailedSheetView: View {
    @EnvironmentObject private var router: LoginRouter
    @State private var isVisible: Bool = false
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image.livithIcon(.cautionTriangleBig)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 16)
                
                Text(Literals.title)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.top, 4)
                
                Text(Literals.description)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.top, 4)
                
                Button {
                    Task { @MainActor in
                        withAnimation(.easeOut(duration: 0.3)) {
                            isVisible = false
                        }
                        
                        try? await Task.sleep(for: .seconds(0.4))
                        router.popToRoot()
                        router.dismissFullScreen()
                    }
                } label: {
                    Text(Literals.backButtonText)
                        .notosans(.body2Medium)
                        .foregroundColor(.livithColor(.black100))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.livithColor(.transition))
                        .cornerRadius(4)
                }
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)
            }
            .frame(width: 328, height: 200)
            .background(Color.livithColor(.black90))
            .cornerRadius(12)
        }
        .opacity(isVisible ? 1 : 0)
        .presentationBackground(.clear)
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.4))
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = true
                }
            }
        }
    }
}

// MARK: - Literals

private extension SignupFailedSheetView {
    enum Literals {
        static let title = "오류가 발생했어요!"
        static let description = "잠시 후 다시 시도해주세요"
        static let backButtonText = "로그인으로 돌아가기"
    }
}
