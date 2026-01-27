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
        if let action = action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
    
    private var content: some View {
        ZStack {
            AsyncImageView(
                url: imageURL,
                contentMode: .fill
            ) {
                Color.livithColor(.black80)
            }

            Color(hex: Layout.overlayHex, opacity: Layout.overlayOpacity)

            Text(title)
                .font(.notosans(.body2Semibold))
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Layout.horizontalPadding)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius)
                .stroke(
                    Color.livithColor(.yellow30),
                    lineWidth: isSelected ? Layout.borderWidth : 0
                )
        )
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedItem: String? = "J-POP"
        private let sampleImageURL = URL(string: "https://fastly.picsum.photos/id/505/108/108.jpg?hmac=uPOmgL2cSvfqXRghDJGQ5yjBf28eqS2eL2AlW7JKt2Q")

        private func item(title: String, imageURL: URL?) -> some View {
            VStack(spacing: 6) {
                PreferenceCard(
                    title: title,
                    imageURL: imageURL,
                    isSelected: selectedItem == title,
                    action: { selectedItem = title }
                )
                Text(selectedItem == title ? "선택" : "비선택")
                    .font(.notosans(.caption2Regular))
                    .foregroundStyle(Color.livithColor(selectedItem == title ? .yellow30 : .black50))
            }
        }

        var body: some View {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    item(title: "클래식/재즈", imageURL: sampleImageURL)
                    item(title: "J-POP", imageURL: sampleImageURL)
                }

                Divider().background(Color.livithColor(.black80))

                HStack(spacing: 12) {
                    item(title: "힙합/랩", imageURL: nil)
                    item(title: "R&B/소울", imageURL: nil)
                }
            }
            .padding()
            .background(Color.livithColor(.black100))
        }
    }

    return PreviewWrapper()
}
