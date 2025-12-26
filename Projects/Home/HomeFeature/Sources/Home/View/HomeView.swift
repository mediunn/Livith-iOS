//
//  HomeView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct HomeView: View {
    @Environment(HomeRouter.self) var router
    
    @Binding var nickname: String

    @State private var sections: [ConcertSection] = ConcertSection.mockSections
    
    var body: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()
            
            ScrollView {
                VStack(spacing: .zero) {
                    HomeHeaderView(
                        nickname: nickname,
                        action: {
                            // TODO: 관심 콘서트 설정 화면으로 이동
                        }
                    )
                    
                    ForEach(sections, id: \.id) { section in
                        concertSectionRow(for: section)
                            .padding(.top, 28)
                            .padding(.leading, 16)
                    }
                    
                    Spacer(minLength: Constants.emptySpaceHeight)
                }
                .background(.livithColor(.black100))
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(.livithColor(.black90))
    }
}

// MARK: - Helper

private extension HomeView {
    func concertSectionRow(for section: ConcertSection) -> some View {
        ConcertSectionView(
            concertSection: section,
            onConcertTap: { concert in
                // TODO: Router를 이용한 콘서트 상세 화면 이동 + Concert 전달
            }
        )
    }
}

// MARK: - Constants

private extension HomeView {
    enum Constants {
        static let emptySpaceHeight: CGFloat = 210
    }
}

#Preview {
    let nickname = Binding.constant("유지미")
    let router = HomeRouter(nickname: nickname)
    return HomeView(nickname: nickname)
        .environment(router)
}
