//
//  NotchedConcertPosterImageView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

public struct NotchedConcertPosterImageView: View {
    let url: URL?
    let image: UIImage?
    
    public init(url: URL?, image: UIImage? = nil) {
        self.url = url
        self.image = image
    }
    
    public var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.livithColor(.black90)
                }
            }
        }
        .clipped()
        .overlay(content: {
            BackgroundGradientView()
        })
        .mask { notchedCardShape }
        .overlay(
            notchedCardShape
                .stroke(Color(hex: "2f3745"), lineWidth: 1)
        )
        .shadow(radius: 5)
    }
}

private extension NotchedConcertPosterImageView {
    var notchedCardShape: some Shape {
        NotchedCardShape(cornerRadius: 8, notchSize: .init(width: 10, height: 20), notchBottomOffset: 28)
    }
}

#Preview {
    NotchedConcertPosterImageView(url: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!)
        .frame(width: 130, height: 174)
}
