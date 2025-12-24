//
//  ExploreEmptyView.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ExploreEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image.livithImage(.livithEmpty)
                .resizable()
                .frame(width: 52, height: 40)
            
            Text("아직 탐색할 콘텐츠가 없어요")
                .notosans(.body2Medium)
                .foregroundStyle(.livithColor(.black80))
                .padding(.top, 16)
        }
    }
}

#Preview {
    ExploreEmptyView()
        .background(.livithColor(.black100))
}
