//
//  NotchedRectangleShape.swift
//  DSKit
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

/// 오른쪽 하단에 삼각형 홈이 있는 둥근 문서 모양의 Shape입니다.
public struct NotchedRectangleShape: Shape {
    let cornerRadius: CGFloat
    // 홈의 전체 높이
    let notchHeight: CGFloat
    // 홈이 안쪽으로 파인 깊이
    let notchDepth: CGFloat
    // 밑변에서 홈의 시작점까지의 거리 (이미지 비율에 맞춰 조정)
    let notchBottomOffset: CGFloat
    
    public init(
        cornerRadius: CGFloat = 8,
        notchHeight: CGFloat = 20,
        notchDepth: CGFloat = 10,
        notchBottomOffset: CGFloat = 40
    ) {
        self.cornerRadius = cornerRadius
        self.notchHeight = notchHeight
        self.notchDepth = notchDepth
        self.notchBottomOffset = notchBottomOffset
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 경로 그리기를 시작할 지점 (왼쪽 상단 코너의 끝부분)
        let startPoint = CGPoint(x: rect.minX + cornerRadius, y: rect.minY)
        path.move(to: startPoint)
        
        // 1. 상단 선과 오른쪽 상단 코너
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // 홈(Notch) 관련 좌표 계산
        let notchTopY = rect.maxY - notchBottomOffset - notchHeight
        let notchPeakY = rect.maxY - notchBottomOffset - (notchHeight / 2.0)
        let notchBottomY = rect.maxY - notchBottomOffset
        
        // 2. 오른쪽 면 (홈 시작 전까지)
        path.addLine(to: CGPoint(x: rect.maxX, y: notchTopY))
        
        // 3. 홈 그리기 (안쪽으로 파고 들었다가 다시 나옴)
        // 홈의 꼭지점
        path.addLine(to: CGPoint(x: rect.maxX - notchDepth, y: notchPeakY))
        // 홈의 하단부로 복귀
        path.addLine(to: CGPoint(x: rect.maxX, y: notchBottomY))
        
        // 4. 오른쪽 면 하단과 오른쪽 하단 코너
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        // 5. 하단 선과 왼쪽 하단 코너
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // 6. 왼쪽 선과 왼쪽 상단 코너 (시작점으로 연결)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}

