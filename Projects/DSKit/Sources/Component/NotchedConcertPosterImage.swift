//
//  NotchedConcertPosterImage.swift
//  DSKit
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct NotchedConcertPosterImage: View {
    let url: URL?
    
    public init(url: URL?) {
        self.url = url
    }
    
    public var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Color.livithColor(.black90)
        }
        .clipped()
        .overlay(content: {
            BackgroundGradient()
        })
        .clipShape(NotchedRectangleShape(cornerRadius: 8, notchHeight: 20, notchDepth: 10, notchBottomOffset: 40))
        .overlay(
            NotchedRectangleShape(cornerRadius: 8, notchHeight: 20, notchDepth: 10, notchBottomOffset: 40)
                .stroke(Color(hex: "2f3745"), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NotchedConcertPosterImage(url: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!)
        .frame(width: 130, height: 174)
}
