//
//  HomeInterestConcertBottomSheetView.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct HomeInterestConcertBottomSheetView: View {
    let onChangeMainConcert: () -> Void
    let onDeleteConcert: () -> Void
    
    var body: some View {       
        VStack(alignment: .leading, spacing: 12) {
            actionButton(
                icon: .livithIcon(.change),
                title: "메인 콘서트 바꾸기",
                action: onChangeMainConcert
            )
            
            actionButton(
                icon: .livithIcon(.trash),
                title: "콘서트 삭제하기",
                action: onDeleteConcert,
                isDestructive: true
            )
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Subviews

private extension HomeInterestConcertBottomSheetView {
    @ViewBuilder
    func actionButton(
        icon: Image,
        title: String,
        action: @escaping () -> Void,
        isDestructive: Bool = false
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                icon
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(isDestructive ? .livithColor(.translation) : .livithColor(.white100))
                    .padding([.vertical, .leading], 8)
                
                Text(title)
                    .notosans(.body2Semibold)
                    .foregroundStyle(isDestructive ? .livithColor(.translation) : .livithColor(.white100))
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeInterestConcertBottomSheetView(
        onChangeMainConcert: { print("Change main concert") },
        onDeleteConcert: { print("Delete concert") }
    )
    .background(.livithColor(.black90))
}
