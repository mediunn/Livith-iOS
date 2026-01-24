//
//  LivithModal.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Modal Type

public enum LivithModalType {
    case welcome(nickname: String)
    case error(title: String, message: String)
}

// MARK: - LivithModal

public struct LivithModal: View {

    // MARK: - Property

    private let type: LivithModalType
    private let confirmTitle: String
    private let onConfirm: (() -> Void)?

    @State private var isVisible: Bool = false

    // MARK: - Initializer

    public init(
        type: LivithModalType,
        confirmTitle: String = "확인",
        onConfirm: (() -> Void)? = nil
    ) {
        self.type = type
        self.confirmTitle = confirmTitle
        self.onConfirm = onConfirm
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .opacity(0.9)
                .ignoresSafeArea()

            modalContent
        }
        .opacity(isVisible ? 1 : 0)
        .presentationBackground(.clear)
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.4))
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = true
                }
            }
        }
    }

    private var modalContent: some View {
        VStack(alignment: .center, spacing: 0) {
            headerImage
                .padding(.top, 16)
                .padding(.trailing, isWelcomeType ? 20 : 0)

            titleText
                .padding(.top, isWelcomeType ? 8 : 4)

            messageText
                .padding(.top, isWelcomeType ? 8 : 4)

            confirmButton
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)
        }
        .frame(width: 328)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            if isWelcomeType {
                Image.livithImage(.polygon)
            }
        }
    }
}

// MARK: - Computed Properties

private extension LivithModal {
    var isWelcomeType: Bool {
        if case .welcome = type { return true }
        return false
    }

    var title: String {
        switch type {
        case .welcome(let nickname):
            return "\(nickname)님,\n라이빗에 어서오세요!"
        case .error(let title, _):
            return title
        }
    }

    var message: String {
        switch type {
        case .welcome:
            return "라이빗과 즐거운 내한 공연을 준비해 볼까요?"
        case .error(_, let message):
            return message
        }
    }

    var buttonTitle: String {
        switch type {
        case .welcome:
            return "시작하기"
        case .error:
            return confirmTitle
        }
    }

    var buttonVariant: LivithButtonVariant {
        switch type {
        case .welcome:
            return .primary
        case .error:
            return .pink
        }
    }
}

// MARK: - Subviews

private extension LivithModal {
    var headerImage: some View {
        Group {
            switch type {
            case .welcome:
                Image.livithImage(.welcome)
                    .resizable()
                    .frame(width: 40, height: 40)
            case .error:
                Image.livithIcon(.cautionTriangleBig)
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
    }

    var titleText: some View {
        Text(title)
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.white100))
            .multilineTextAlignment(.center)
    }

    var messageText: some View {
        Text(message)
            .notosans(.body4Regular)
            .foregroundStyle(Color.livithColor(.black30))
    }

    var confirmButton: some View {
        LivithButton(buttonTitle, variant: buttonVariant, cornerRadius: 4) {
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }

                try? await Task.sleep(for: .seconds(0.4))
                onConfirm?()
            }
        }
    }
}

// MARK: - Preview

#Preview("Welcome") {
    LivithModal(
        type: .welcome(nickname: "유지미"),
        onConfirm: { }
    )
}

#Preview("Error") {
    LivithModal(
        type: .error(title: "탈퇴 후 7일이 지나지 않았어요", message: "7일이 지난 후 다시 시도해주세요"),
        confirmTitle: "로그인으로 돌아가기",
        onConfirm: { }
    )
}
