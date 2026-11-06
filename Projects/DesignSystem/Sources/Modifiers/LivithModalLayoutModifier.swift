//
//  LivithModalLayoutModifier.swift
//  LivithDesignSystem
//
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

struct ModalToastMessageKey: PreferenceKey {
    static let defaultValue: String? = nil

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

private struct LivithModalLayoutModifier: ViewModifier {

    // MARK: - Properties

    private let avoidsKeyboard: Bool

    @State private var keyboardHeight: CGFloat = 0
    @State private var toastMessage: String?

    // MARK: - Initializer

    init(avoidsKeyboard: Bool) {
        self.avoidsKeyboard = avoidsKeyboard
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                    .offset(y: avoidsKeyboard && keyboardHeight > 0 ? -(keyboardHeight / 2) : 0)
                    .animation(.easeInOut(duration: 0.25), value: keyboardHeight)

                if let toastMessage {
                    LivithToast(type: .failure, message: toastMessage)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height - keyboardHeight - 20 - 27
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .ignoresSafeArea(.keyboard)
        .onPreferenceChange(ModalToastMessageKey.self) { message in
            toastMessage = message
        }
        .onAppear {
            guard avoidsKeyboard else { return }
            keyboardHeight = KeyboardHeightObserver.shared.height
        }
        .onReceive(KeyboardHeightObserver.shared.$height) { height in
            guard avoidsKeyboard else { return }
            keyboardHeight = height
        }
    }
}

public extension View {
    /// 모달의 중앙 배치, 키보드 회피, 입력 안내의 표시 위치를 관리합니다.
    func livithModalLayout(avoidsKeyboard: Bool = false) -> some View {
        modifier(LivithModalLayoutModifier(avoidsKeyboard: avoidsKeyboard))
    }
}
