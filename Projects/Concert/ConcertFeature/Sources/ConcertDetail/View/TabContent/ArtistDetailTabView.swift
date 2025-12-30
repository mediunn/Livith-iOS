//
//  ArtistDetailTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ArtistDetailTabView: View {

    // MARK: - Body

    var body: some View {
        // TODO: 아티스트 상세 콘텐츠 구현
        Text("아티스트 상세 콘텐츠")
            .foregroundStyle(Color.livithColor(.white100))
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }
}

#Preview {
    ArtistDetailTabView()
        .background(Color.livithColor(.black100))
}
