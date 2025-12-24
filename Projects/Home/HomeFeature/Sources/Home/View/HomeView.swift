//
//  HomeView.swift
//  Home
//
//  Created by Youjin Lee on 12/3/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct HomeView: View {
    var body: some View {
        VStack(spacing: .zero) {
            LivithLogoHeaderView()
            
            Text("이것은 홈 화면입니다.")
                .notosans(.title)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.livithColor(.black90))
    }
}

#Preview {
    HomeView()
}
