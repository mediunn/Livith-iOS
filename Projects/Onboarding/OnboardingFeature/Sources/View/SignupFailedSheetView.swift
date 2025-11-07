//
//  SignupFailedSheetView.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import DesignSystem

struct SignupFailedSheetView: View {
    @EnvironmentObject private var router: OnboardingRouter
    // 각 요소의 등장 여부를 제어하는 State 변수
    @State private var isVisible = true
    
    var body: some View {
        ZStack {
            Color.livithColor(.black100).opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image.livithIcon(.cautionTriangleBig)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 16)
                
                Text("오류가 발생했어요!")
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.top, 4)
                
                Text("처음부터 다시 시도해주세요")
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.top, 4)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        router.dismissFullScreen()
                        
                        // TODO: 로그인 화면으로 돌아가기
                        
                    }
                } label: {
                    Text("처음으로 돌아가기")
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
        .presentationBackground(.clear)
    }
}

#Preview {
    SignupFailedSheetView()
        .environmentObject(OnboardingRouter())
}
