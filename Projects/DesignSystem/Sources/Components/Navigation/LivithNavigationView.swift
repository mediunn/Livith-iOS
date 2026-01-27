//
//  LivithNavigationView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - LivithNavigationViewType

public enum LivithNavigationViewType {
    case logo(hasNewNotice: Bool = false, onNoticeTap: (() -> Void)? = nil)
    case back(title: String, onBack: () -> Void)
    case backOnly(onBack: () -> Void)

    var height: CGFloat {
        switch self {
        case .logo: return 60
        case .back, .backOnly: return 66
        }
    }
}

// MARK: - LivithNavigationView

public struct LivithNavigationView: View {

    // MARK: - Property

    private let type: LivithNavigationViewType

    // MARK: - Initializer

    public init(type: LivithNavigationViewType) {
        self.type = type
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch type {
            case .logo(let hasNewNotice, let onNoticeTap):
                logoContent(hasNewNotice: hasNewNotice, onNoticeTap: onNoticeTap)
            case .back(let title, let onBack):
                backContent(title: title, onBack: onBack)
            case .backOnly(let onBack):
                backOnlyContent(onBack: onBack)
            }
        }
        .frame(height: type.height)
    }
}

// MARK: - Subviews

private extension LivithNavigationView {
    func logoContent(hasNewNotice: Bool, onNoticeTap: (() -> Void)?) -> some View {
        HStack(alignment: .center) {
            Image.livithImage(.livithLogo)
                .resizable()
                .frame(width: 100, height: 24)
                .padding(.leading, 16)

            Spacer()

            if let onNoticeTap {
                Button(action: onNoticeTap) {
                    Image.livithIcon(hasNewNotice ? .noticeEnabled : .noticeDefault)
                }
                .padding(.trailing, 16)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    func backContent(title: String, onBack: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Button(action: onBack) {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 36, height: 36)
            }
            .padding(.leading, 16)

            Text(title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)

            Spacer()
        }
        .padding(.top, 12)
    }

    func backOnlyContent(onBack: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onBack) {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 38, height: 38)
            }
            .padding(.leading, 16)

            Spacer()
        }
        .padding(.top, 12)
    }
}

// MARK: - Preview

#Preview("Logo Type") {
    VStack {
        LivithNavigationView(type: .logo())
        Spacer()
    }
    .background(Color.livithColor(.black100))
}

#Preview("Logo with Notice") {
    VStack {
        LivithNavigationView(type: .logo(hasNewNotice: false, onNoticeTap: {}))
        LivithNavigationView(type: .logo(hasNewNotice: true, onNoticeTap: {}))
        Spacer()
    }
    .background(Color.livithColor(.black100))
}

#Preview("Back Type") {
    VStack {
        LivithNavigationView(type: .back(title: "공연 설정하기", onBack: {}))
        Spacer()
    }
    .background(Color.livithColor(.black100))
}
