//
//  ExploreSearchButton.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/18/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ExploreSearchButton: View {
    @EnvironmentObject private var router: ExploreRouter
    
    var body: some View {
        Button {
            // TODO: 검색 뷰로 이동
//                router.push(.search)
        } label: {
            HStack {
                Text("찾고 있는 콘서트나 가수를 검색하세요")
                    .notosans(.body3Medium)
                    .foregroundColor(.livithColor(.black50))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                
                Image.livithIcon(.searchLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .padding(.vertical, 8)
                    .padding(.trailing, 12)
            }
            .background(
                Color.livithColor(.black90)
            )
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    ExploreSearchButton()
        .background(Color.livithColor(.black100))
}
