//
//  InterestTempView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct InterestTempView: View {
    @Environment(HomeCoordinator.self) var coordinator
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Button(action: {
                    coordinator.pop()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("뒤로")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray).opacity(0.15))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer().frame(height: 24)

            Text("임시 Interest 뷰")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top, 16)

            Spacer()
        }
        .background(.livithColor(.black90))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    let nickname = Binding.constant("유지미")
    let coordinator = HomeCoordinator(nickname: nickname)
    return InterestTempView()
        .environment(coordinator)
}
