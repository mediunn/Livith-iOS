//
//  CalloutChipView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

struct CalloutChipView: View {
    let text: String
    let targetText: String?
    
    init(text: String, targetText: String? = nil) {
        self.text = text
        self.targetText = targetText
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#2f3745"))
                .frame(height: 36)
                .overlay {
                    Text(attributedString)
                        .notosans(.caption1Bold)
                }
            
            TriangleTail()
                .fill(Color(hex: "#2f3745"))
                .frame(width: 16, height: 12)
                .offset(y: 12)
                
        }
        .frame(height: 48)
    }
}

// MARK: - Helper

private extension CalloutChipView {
    var attributedString: AttributedString {
        var attributedString = AttributedString(text)
        attributedString.foregroundColor = .livithColor(.black50)
        
        if let targetText = targetText,
           let range = attributedString.range(of: targetText) {
            attributedString[range].foregroundColor = .livithColor(.black5)
        }
        
        return attributedString
    }
}

// MARK: - 말풍선 꼬리

private extension CalloutChipView {
    struct TriangleTail: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
            return path
        }
    }
}

#Preview {
    CalloutChipView(
        text: "회원가입하고 모든 서비스 이용해보세요!",
        targetText: "모든 서비스 이용"
    )
}
