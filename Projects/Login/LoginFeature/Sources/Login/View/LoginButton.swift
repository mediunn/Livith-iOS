//
//  LoginButton.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

struct LoginButton: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    let icon: Image
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                icon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 20)
                    .padding(.vertical, 16)
                
                Spacer()
                
                Text(title)
                    .notosans(.body3Medium)
                    .foregroundStyle(textColor)
                
                Spacer()
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: 40)
            }
            .frame(height: 52)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    LoginButton(
        title: "카카오로 시작하기",
        backgroundColor: .init(hex: "#fce64a"),
        textColor: .init(hex: "#14171b"),
        icon: .livithIcon(.kakao),
        action: { print("로그인 버튼 눌림.") }
    )
}
