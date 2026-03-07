//
//  InterestConcertSettingButton.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct InterestConcertSettingButton: View {
    @State private var isRotating = false
    @State private var rotationTask: Task<Void, Never>?
    
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

// MARK: - Subviews

private extension InterestConcertSettingButton {
    var iconContainer: some View {
        ZStack {
            Image.livithIcon(.plusLineSmall)
                .resizable()
                .frame(width: 36, height: 36)
                .padding(4)
                .rotationEffect(.degrees(isRotating ? 180 : 0))
                .onAppear {
                    startRotationTask()
                }
                .onDisappear {
                    stopRotationTask()
                }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.livithColor(.black90))
        )
    }
}

// MARK: - Helpers

private extension InterestConcertSettingButton {
    func startRotationTask() {
        rotationTask?.cancel()
        rotationTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2.0))
                guard !Task.isCancelled else { break }
                
                await MainActor.run {
                    withAnimation(.linear(duration: 0.5)) {
                        isRotating = true
                    }
                }
                
                try? await Task.sleep(for: .seconds(0.5))
                guard !Task.isCancelled else { break }
                
                await MainActor.run {
                    isRotating = false
                }
            }
        }
    }
    
    func stopRotationTask() {
        rotationTask?.cancel()
        rotationTask = nil
        isRotating = false
    }
}

#Preview {
    ZStack {
        Color.livithColor(.black90)
            .ignoresSafeArea()
        
        InterestConcertSettingButton {
            print("버튼이 눌렸다.")
        }
    }
}
