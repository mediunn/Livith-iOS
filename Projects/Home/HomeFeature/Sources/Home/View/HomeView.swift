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
    @Environment(\.homeCoordinator) var coordinator
    
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
                            coordinator?.push(to: .interest)
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
                coordinator?.push(to: .concertDetail(concertID: concert.id))
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
    let coordinator = HomeCoordinator(nickname: nickname)
    HomeView(nickname: nickname)
        .environment(\.homeCoordinator, coordinator)
}
