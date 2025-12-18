//
//  ExploreView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ExploreView: View {
    @EnvironmentObject private var router: ExploreRouter
    
    var body: some View {
        VStack {
            ExploreLogoView()
            
            ZStack {
                ExploreSearchButton()
                
                // TODO: 스크롤 되는 섹션들 구현하기
            }
            
            Spacer()
        }
        .background(Color.livithColor(.black100))
    }
}

#Preview {
    ExploreView()
}
