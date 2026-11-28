//
//  PreferenceCard.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 1/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

/// 선호도 선택을 위한 카드 컴포넌트
///
/// 이미지 배경 위에 텍스트가 표시되며, 선택 시 노란색 테두리가 표시됩니다.
///
/// 사용 예시:
/// ```swift
/// PreferenceCard(
///     title: "클래식/재즈",
///     imageURL: URL(string: "https://example.com/image.jpg"),
///     isSelected: selectedGenre == "classical",
///     action: { selectedGenre = "classical" }
/// )
/// ```
public struct PreferenceCard: View {
    
    // MARK: - Layout
    
    private enum Layout {
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 2
        static let horizontalPadding: CGFloat = 4
        static let overlayOpacity: Double = 0.7
        static let overlayHex: String = "14171B"
    }
    
    // MARK: - Properties
    
    private let title: String
    private let imageURL: URL?
    private let isSelected: Bool
    private let action: (() -> Void)?
    
    // MARK: - Initializer
    
    /// PreferenceCard 초기화
    /// - Parameters:
    ///   - title: 카드에 표시될 텍스트
    ///   - imageURL: 배경 이미지 URL
    ///   - isSelected: 선택 상태
    ///   - action: 카드 선택 시 실행될 액션 (nil이면 버튼이 아닌 뷰로 렌더링 됩니다)
    public init(
        title: String,
        imageURL: URL?,
        isSelected: Bool,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.imageURL = imageURL
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(
                    Color.livithColor(.yellow30),
                    lineWidth: isSelected ? Layout.borderWidth : 0
                )
        )
    }
    
    private var content: some View {
        Text(title)
            .notosans(.body2Semibold)
            .foregroundStyle(Color.livithColor(.white100))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                backgroundImage
                    .overlay(Color(hex: Layout.overlayHex, opacity: Layout.overlayOpacity))
            }
    }
    
    private var backgroundImage: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure(_):
                Color.livithColor(.black80)
            @unknown default:
                Color.livithColor(.black80)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedItem: String? = "J-POP"
        private let sampleImageURL = URL(string: "https://picsum.photos/id/1047/300/180")
        private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

        private var sampleList: [(title: String, imageURL: URL?)] {
            [
                ("J-POP", URL(string: "https://picsum.photos/id/505/300/300")),
                ("락/메탈", URL(string: "https://picsum.photos/id/1047/300/180")),
                ("랩/힙합", URL(string: "https://picsum.photos/id/1027/180/300")),
                ("INDIE", sampleImageURL),
                ("POP", sampleImageURL),
                ("클래식/재즈", nil)
            ]
        }

        var body: some View {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(sampleList, id: \.title) { item in
                    PreferenceCard(
                        title: item.title,
                        imageURL: item.imageURL,
                        isSelected: selectedItem == item.title,
                        action: { selectedItem = item.title }
                    )
                }
            }
            .padding()
            .background(Color.livithColor(.black100))
        }
    }

    return PreviewWrapper()
}
