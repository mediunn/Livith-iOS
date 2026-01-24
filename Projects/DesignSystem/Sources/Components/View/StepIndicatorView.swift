//
//  StepIndicatorView.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 1/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

/// 온보딩 또는 다단계 프로세스의 진행 상태를 표시하는 Step Indicator 컴포넌트
///
/// - Parameters:
///   - currentStep: 현재 진행 중인 단계 (1부터 시작)
///   - totalSteps: 전체 단계 수
///
/// 현재 단계까지는 yellow30 색상으로 표시되며, 이후 단계는 black80 색상으로 표시됩니다.
public struct StepIndicatorView: View {
    private let currentStep: Int
    private let totalSteps: Int
    
    /// Step Indicator를 생성합니다
    /// - Parameters:
    ///   - currentStep: 현재 진행 중인 단계 (1부터 시작)
    ///   - totalSteps: 전체 단계 수
    public init(currentStep: Int, totalSteps: Int) {
        self.currentStep = max(1, min(currentStep, totalSteps))
        self.totalSteps = max(1, totalSteps)
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(Color.livithColor(step <= currentStep ? .yellow30 : .black80))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Preview

#Preview("기본") {
    VStack(spacing: 20) {
        StepIndicatorView(currentStep: 1, totalSteps: 2)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 2, totalSteps: 2)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 1, totalSteps: 3)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 2, totalSteps: 3)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 3, totalSteps: 3)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 4, totalSteps: 4)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 3, totalSteps: 4)
            .padding(.horizontal, 16)
    }
    .padding(.vertical, 16)
    .background(Color.livithColor(.black100))
}

#Preview("Edge Cases") {
    VStack(spacing: 20) {
        // 단계가 1개인 경우
        StepIndicatorView(currentStep: 1, totalSteps: 1)
            .padding(.horizontal, 16)
        
        // 범위를 벗어난 currentStep (자동으로 보정됨)
        StepIndicatorView(currentStep: 0, totalSteps: 2)
            .padding(.horizontal, 16)
        
        StepIndicatorView(currentStep: 5, totalSteps: 2)
            .padding(.horizontal, 16)
    }
    .padding()
    .background(Color.livithColor(.black100))
}
