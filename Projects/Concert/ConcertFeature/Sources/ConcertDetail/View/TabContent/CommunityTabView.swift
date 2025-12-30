//
//  CommunityTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct CommunityTabView: View {

    // MARK: - Body

    var body: some View {
        // TODO: 소통·댓글 콘텐츠 구현
        Text("소통·댓글 콘텐츠")
            .foregroundStyle(Color.livithColor(.white100))
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }
}

#Preview {
    CommunityTabView()
        .background(Color.livithColor(.black100))
}
