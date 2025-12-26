//
//  HomeHeaderView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct HomeHeaderView: View {
    let nickname: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(nickname)님,\n기다리는\n콘서트가 있나요?")
                .notosans(.headSemibold)
                .foregroundStyle(.livithColor(.white100))
                .padding(.leading, 16)
                .padding(.top, 32)
            
            Spacer(minLength: 44)
            
            InterestedConcertSettingButton(action: action)
                .padding(.trailing, 16)
                .padding(.top, 24)
                .padding(.bottom, 28)
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 0,
                    topTrailing: 0
                )
            )
            .fill(.livithColor(.black90))
        )
    }
}

#Preview {
    HomeHeaderView(nickname: "유지미", action: {
        print("Tapped")
    })
}
