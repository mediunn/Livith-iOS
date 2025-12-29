//
//  DefaultHomeView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct DefaultHomeView: View {
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

private extension DefaultHomeView {
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

private extension DefaultHomeView {
    enum Constants {
        static let emptySpaceHeight: CGFloat = 210
    }
}
