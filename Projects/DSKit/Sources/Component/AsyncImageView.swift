//
//  AsyncImageView.swift
//  DSKit
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Kingfisher

/// 이미지 로드 성공 시에만 표시되는 AsyncImage 컴포넌트
/// 로드 실패 시 placeholder 표시 또는 뷰 자체가 제거됨
public struct AsyncImageView: View {

    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let showGradient: Bool
    private let placeholder: Image?

    @State private var didFail: Bool = false

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        showGradient: Bool = false,
        placeholder: Image? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.showGradient = showGradient
        self.placeholder = placeholder
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
                            BackgroundGradient(
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
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .clipped()
        }
    }
}
