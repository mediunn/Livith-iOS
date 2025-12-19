//
//  BannerPageIndicator.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct BannerPageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                if index == currentPage {
                    Capsule()
                        .fill(Color.livithColor(.yellow30))
                        .frame(width: 28, height: 4)
                } else {
                    Circle()
                        .fill(Color.livithColor(.yellow30))
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BannerPageIndicator(currentPage: 0, pageCount: 5)
        BannerPageIndicator(currentPage: 2, pageCount: 5)
        BannerPageIndicator(currentPage: 4, pageCount: 5)
    }
    .padding()
    .background(Color.black)
}
