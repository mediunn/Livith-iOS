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
        .mask { notchedCardShape }
        .overlay(
            notchedCardShape
                .stroke(Color(hex: "2f3745"), lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}

private extension NotchedConcertPosterImage {
    var notchedCardShape: some Shape {
        NotchedCardShape(cornerRadius: 8, notchSize: .init(width: 10, height: 20), notchBottomOffset: 28)
    }
}

#Preview {
    NotchedConcertPosterImage(url: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!)
        .frame(width: 130, height: 174)
}
