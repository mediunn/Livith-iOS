//
//  BannerCell.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct BannerCell: View {
    let imageURL: URL?
    let category: String
    let title: String
    let description: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            imageView
                        
            VStack(alignment: .leading, spacing: 0) {
                categoryChip
                
                titleText
                    .padding(.top, 8)
                
                descriptionText
                    .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 52)
        }
    }
}

private extension BannerCell {
    var imageView: some View {
        Group {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .frame(height: 365)
                    default:
                        Color.livithColor(.black80)
                    }
                }
            } else {
                Color.livithColor(.black80)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .overlay {
            BackgroundGradient()
        }
    }
    
    var categoryChip: some View {
        LivithChip(category, style: .dark)
    }
    
    var titleText: some View {
        Text(title)
            .notosans(.title)
            .foregroundStyle(Color.livithColor(.white100))
    }
    
    var descriptionText: some View {
        Text(description)
            .notosans(.body3Medium)
            .foregroundStyle(Color.livithColor(.black50))
    }
}

#Preview {
    let url = URL(string: "https://fastly.picsum.photos/id/643/365/365.jpg?hmac=ltH7rZPrQvX1Lwm0WY-aAWvyxAsOrqwmWilmxnn_GJY")!
    let category = "라이빗 팀블로그"
    let title = "iOS 개발자가 알아두면 좋은 SwiftUI 팁 5가지"
    let description = "SwiftUI를 더 효과적으로 활용할 수 있는 다섯 가지 유용한 팁을 소개합니다."
    
    BannerCell(
        imageURL: url,
        category: category,
        title: title, 
        description: description
    )
    .frame(height: 365)
}
