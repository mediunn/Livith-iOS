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
    case normal(title: String, message: String)
}

// MARK: - LivithModal

public struct LivithModal: View {

    // MARK: - Property

    private let type: LivithModalType
    private let confirmTitle: String
    private let onConfirm: (() -> Void)?

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
        modalContent
    }

    private var modalContent: some View {
        VStack(alignment: .center, spacing: 0) {
            if !isNormalType {
                headerImage
                    .padding(.top, 16)
                    .padding(.trailing, isWelcomeType ? 20 : 0)
            }

            titleText
                .padding(.top, isNormalType ? 24 : (isWelcomeType ? 8 : 4))

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

    var isNormalType: Bool {
        if case .normal = type { return true }
        return false
    }

    var title: String {
        switch type {
        case .welcome(let nickname):
            return "\(nickname)님,\n라이빗에 어서오세요!"
        case .error(let title, _):
            return title
        case .normal(let title, _):
            return title
        }
    }

    var message: String {
        switch type {
        case .welcome:
            return "라이빗과 즐거운 내한 공연을 준비해 볼까요?"
        case .error(_, let message):
            return message
        case .normal(_, let message):
            return message
        }
    }

    var buttonTitle: String {
        switch type {
        case .welcome:
            return "시작하기"
        case .error, .normal:
            return confirmTitle
        }
    }

    var buttonVariant: LivithButtonVariant {
        switch type {
        case .welcome, .normal:
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
            case .normal:
                EmptyView()
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
            .multilineTextAlignment(.center)
    }

    var confirmButton: some View {
        LivithButton(buttonTitle, variant: buttonVariant, cornerRadius: 4) {
            onConfirm?()
        }
    }
}

// MARK: - Preview

private struct LivithModalPreviewContainer: View {
    @State private var isWelcomePresented = false
    @State private var isErrorPresented = false
    @State private var isNormalPresented = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Button("Welcome Modal 보기") {
                    isWelcomePresented = true
                }

                Button("Error Modal 보기") {
                    isErrorPresented = true
                }

                Button("Normal Modal 보기") {
                    isNormalPresented = true
                }
            }
        }
        .crossDissolve(isPresented: $isWelcomePresented, dismissOnTapOutside: true) {
            LivithModal(
                type: .welcome(nickname: "유지미"),
                onConfirm: { isWelcomePresented = false }
            )
        }
        .crossDissolve(isPresented: $isErrorPresented, dismissOnTapOutside: true) {
            LivithModal(
                type: .error(title: "탈퇴 후 7일이 지나지 않았어요", message: "7일이 지난 후 다시 시도해주세요"),
                confirmTitle: "로그인으로 돌아가기",
                onConfirm: { isErrorPresented = false }
            )
        }
        .crossDissolve(isPresented: $isNormalPresented, dismissOnTapOutside: true) {
            LivithModal(
                type: .normal(title: "알림 동의 안내", message: "전송자 : 라이빗\n수신 일시 : 2026.01.28 10:00\n처리 내용 : 알림 동의 처리 완료"),
                onConfirm: { isNormalPresented = false }
            )
        }
    }
}

#Preview("Modal Examples") {
    LivithModalPreviewContainer()
}
