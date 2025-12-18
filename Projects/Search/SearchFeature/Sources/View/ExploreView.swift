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
    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
            
            VStack {
                logoView
            }
        }
    }
}

private extension ExploreView {
    var logoView: some View {
        HStack {
            Image.livithImage(.livithLogo)
                .resizable()
                .frame(width: 100, height: 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .padding(.leading, 16)

            Spacer()
        }
    }
}

#Preview {
    ExploreView()
}
