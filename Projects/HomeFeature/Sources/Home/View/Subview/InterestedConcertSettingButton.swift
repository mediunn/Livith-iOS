//
//  InterestedConcertSettingButton.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct InterestedConcertSettingButton: View {
    @State private var isRotating = false
    
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                iconContainer
                    .padding(.top, 32)
                
                Text("관심 콘서트 설정")
                    .notosans(.body4Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.livithColor(.black80))
            )
        }
    }
}

// MARK: - UIComponents

private extension InterestedConcertSettingButton {
    var iconContainer: some View {
        ZStack {
            Image.livithIcon(.plusLineSmall)
                .resizable()
                .frame(width: 36, height: 36)
                .padding(4)
                .rotationEffect(.degrees(isRotating ? 180 : 0))
                .onAppear {
                    startRotationTimer()
                }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.livithColor(.black90))
        )
    }
    
    func startRotationTimer() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.linear(duration: 0.5)) {
                isRotating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isRotating = false
            }
        }
    }
}

#Preview {
    ZStack {
        Color.livithColor(.black90)
            .ignoresSafeArea()
        
        InterestedConcertSettingButton {
            print("버튼이 눌렸다.")
        }
    }
}
