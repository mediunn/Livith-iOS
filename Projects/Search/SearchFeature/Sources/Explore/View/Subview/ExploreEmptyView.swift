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
    let message: String

    init(message: String = "") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 0) {
            Image.livithImage(.livithEmpty)
                .resizable()
                .frame(width: 52, height: 40)
            
            Text(message.isEmpty ? "아직 탐색할 콘텐츠가 없어요" : message)
                .notosans(.body2Medium)
                .foregroundStyle(.livithColor(.black80))
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    VStack {
        ExploreEmptyView()
        ExploreEmptyView(message: "네트워크 오류가 발생했어요. 잠시 후 다시 시도해주세요.")
    }
    .background(.livithColor(.black100))
}
