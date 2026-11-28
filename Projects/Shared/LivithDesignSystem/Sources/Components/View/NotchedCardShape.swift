//
//  NotchedCardShape.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct NotchedCardShape: Shape {
    var cornerRadius: CGFloat
    var notchSize: CGSize // width = 깊이, height = 높이
    var notchBottomOffset: CGFloat // 하단에서부터 노치 시작점까지의 거리
    
    // 기본적인 초기값 설정
    public init(cornerRadius: CGFloat = 8, notchSize: CGSize = CGSize(width: 20, height: 30), notchBottomOffset: CGFloat = 40) {
        self.cornerRadius = cornerRadius
        self.notchSize = notchSize
        self.notchBottomOffset = notchBottomOffset
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 좌표 정의
        let width = rect.width
        let height = rect.height
        
        // 1. 왼쪽 상단 시작점 (둥근 모서리 보정)
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        
        // 2. 상단 선 -> 오른쪽 상단 둥근 모서리
        path.addLine(to: CGPoint(x: width - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        // 3. 오른쪽 수직 선 (노치 시작 전까지)
        // 노치가 위치할 y좌표 계산 (하단에서 노치 높이만큼 위)
        let notchStartY = height - notchSize.height - notchBottomOffset // 하단에서 20pt 띄움
        
        path.addLine(to: CGPoint(x: width, y: notchStartY))
        
        // 4. 노치 그리기 (삼각형 모양으로 파임)
        // 안쪽으로 들어가는 선
        path.addLine(to: CGPoint(x: width - notchSize.width, y: notchStartY + (notchSize.height / 2)))
        // 바깥으로 나오는 선
        path.addLine(to: CGPoint(x: width, y: notchStartY + notchSize.height))
        
        // 5. 오른쪽 하단 나머지 선 -> 오른쪽 하단 둥근 모서리
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        
        // 6. 하단 선 -> 왼쪽 하단 둥근 모서리
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: height))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        
        // 7. 왼쪽 수직 선 -> 시작점으로 닫기
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}
