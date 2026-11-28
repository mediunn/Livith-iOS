//
//  AsyncImageView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Kingfisher

/// 이미지 로드 성공 시에만 표시되는 AsyncImage 컴포넌트
/// 로드 실패 시 placeholder 표시 또는 뷰 자체가 제거됨
public struct AsyncImageView<Placeholder: View>: View {

    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let showGradient: Bool
    private let placeholder: Placeholder?

    @State private var didFail: Bool = false

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        showGradient: Bool = false,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.showGradient = showGradient
        self.placeholder = placeholder()
    }

    public var body: some View {
        Group {
            if didFail {
                placeholderView
            } else if let url {
                KFImage(url)
                    .onFailure { _ in didFail = true }
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipped()
                    .overlay {
                        if showGradient {
                            BackgroundGradientView(
                                baseColor: .livithColor(.black100),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        }
                    }
            } else {
                placeholderView
            }
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if let placeholder {
            placeholder
        }
    }
}

// MARK: - Convenience Initializer (No Placeholder)

extension AsyncImageView where Placeholder == EmptyView {
    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        showGradient: Bool = false
    ) {
        self.url = url
        self.contentMode = contentMode
        self.showGradient = showGradient
        self.placeholder = nil
    }
}
