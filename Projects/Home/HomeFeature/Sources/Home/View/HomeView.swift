//
//  HomeView.swift
//  HomeFeature
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct HomeView: View {
    @Environment(HomeRouter.self) var router
    
    let nickname: String
    
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
                    
                    Text("이것은 홈 화면입니다.")
                        .notosans(.title)
                        .foregroundStyle(Color.livithColor(.white100))
                        .padding(.top, 20)
                    
                    Spacer(minLength: 1000)
                }
                .background(.livithColor(.black100))
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(.livithColor(.black90))
    }
}

#Preview {
    let router = HomeRouter()
    return HomeView(nickname: "유지미")
        .environment(router)
}
