//
//  ConcertRequestView.swift
//  ShareFeature
//
//  Created by JinUng41 on 7/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

public struct ConcertRequestView: View {

    // MARK: - Properties

    @StateObject private var store = ConcertRequestStore()

    @State private var concertName: String
    @State private var urlText: String
    @State private var additionalNote: String
    @State private var isConcertNameFocused: Bool = false
    @State private var isURLFocused: Bool = false
    @State private var isAdditionalNoteFocused: Bool = false
    @State private var isBottomSheetPresented: Bool
    @State private var isCancelModalPresented: Bool

    private let onDismiss: () -> Void
    private let onRequestSuccess: () -> Void

    // MARK: - Initializer

    public init(
        onDismiss: @escaping () -> Void,
        onRequestSuccess: @escaping () -> Void
    ) {
        self.onDismiss = onDismiss
        self.onRequestSuccess = onRequestSuccess
        self._concertName = State(initialValue: "")
        self._urlText = State(initialValue: "")
        self._additionalNote = State(initialValue: "")
        self._isBottomSheetPresented = State(initialValue: false)
        self._isCancelModalPresented = State(initialValue: false)
    }

    init(
        concertName: String,
        urlText: String = "",
        additionalNote: String = "",
        isBottomSheetPresented: Bool = false,
        isCancelModalPresented: Bool = false,
        onDismiss: @escaping () -> Void = {},
        onRequestSuccess: @escaping () -> Void = {}
    ) {
        self.onDismiss = onDismiss
        self.onRequestSuccess = onRequestSuccess
        self._concertName = State(initialValue: concertName)
        self._urlText = State(initialValue: urlText)
        self._additionalNote = State(initialValue: additionalNote)
        self._isBottomSheetPresented = State(initialValue: isBottomSheetPresented)
        self._isCancelModalPresented = State(initialValue: isCancelModalPresented)
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.livithColor(.black100)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        concertNameSection
                        urlSection
                        additionalNoteSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, Constants.scrollBottomPadding)
                }
            }

            submitButton
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            Color.livithColor(.black100).opacity(0),
                            Color.livithColor(.black100)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .ignoresSafeArea(.keyboard)
        .simultaneousGesture(
            TapGesture().onEnded { _ in
                dismissKeyboard()
            }
        )
        .livithSheet(
            isPresented: $isBottomSheetPresented,
            detents: [.fraction(InterestConcertBottomSheet.Constants.sheetFraction)]
        ) {
            InterestConcertBottomSheet(
                onDecline: { submit(shouldAutoRegister: false) },
                onAccept: { submit(shouldAutoRegister: true) }
            )
            .livithToast(
                isPresented: failureToastBinding,
                type: .failure,
                message: Literals.failureToast
            )
        }
        .onChange(of: store.state.didSubmitSucceed) { _, didSucceed in
            guard didSucceed else { return }
            isBottomSheetPresented = false
            onRequestSuccess()
        }
        .crossDissolve(
            isPresented: $isCancelModalPresented,
            dismissOnTapOutside: false
        ) {
            LivithDangerModal(
                message: Literals.cancelMessage,
                confirmTitle: Literals.cancelConfirm,
                cancelTitle: Literals.cancelDismiss,
                type: .confirm(onConfirm: {
                    isCancelModalPresented = false
                    onDismiss()
                }),
                onCancel: {
                    isCancelModalPresented = false
                }
            )
        }
    }
}

// MARK: - Computed Properties

private extension ConcertRequestView {
    var hasInput: Bool {
        !trimmed(concertName).isEmpty
            || !trimmed(urlText).isEmpty
            || !trimmed(additionalNote).isEmpty
    }

    var isSubmitEnabled: Bool {
        !trimmed(concertName).isEmpty
    }

    var failureToastBinding: Binding<Bool> {
        Binding(
            get: { store.state.showFailureToast },
            set: { isPresented in
                if !isPresented {
                    store.send(.onFailureToastDisappear)
                }
            }
        )
    }
}

// MARK: - UIComponents

private extension ConcertRequestView {
    var navigationBar: some View {
        LivithNavigationView(
            type: .back(title: Literals.navigationTitle, onBack: handleBack)
        )
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.headerTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .fixedSize(horizontal: false, vertical: true)

            Text(Literals.headerSubtitle)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var concertNameSection: some View {
        fieldSection(
            title: Literals.concertNameTitle,
            badge: Literals.required
        ) {
            LivithTextField(
                text: $concertName,
                isFocused: $isConcertNameFocused,
                type: .text(maxLength: Constants.concertNameMaxLength),
                placeholder: Literals.concertNamePlaceholder,
                onSubmit: { focusField(.url) }
            )
        }
    }

    var urlSection: some View {
        fieldSection(
            title: Literals.urlTitle,
            badge: Literals.optional
        ) {
            UnlimitedTextField(
                text: $urlText,
                isFocused: $isURLFocused,
                placeholder: Literals.urlPlaceholder,
                submitLabel: .next,
                onSubmit: { focusField(.additionalNote) }
            )
        }
    }

    var additionalNoteSection: some View {
        fieldSection(
            title: Literals.additionalNoteTitle,
            badge: Literals.optional
        ) {
            UnlimitedTextField(
                text: $additionalNote,
                isFocused: $isAdditionalNoteFocused,
                placeholder: Literals.additionalNotePlaceholder,
                isMultiline: true,
                minHeight: Constants.additionalNoteMinHeight
            )
        }
    }

    func fieldSection<Content: View>(
        title: String,
        badge: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text(title)
                    .notosans(.body3Semibold)
                    .foregroundStyle(Color.livithColor(.black30))

                Text(badge)
                    .notosans(.caption1Regular)
                    .foregroundStyle(Color.livithColor(.black50))
            }

            content()
        }
    }

    var submitButton: some View {
        LivithButton(Literals.submit, variant: .primary) {
            dismissKeyboard()
            isBottomSheetPresented = true
        }
        .disabled(!isSubmitEnabled)
    }
}

// MARK: - Helpers

private extension ConcertRequestView {
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum Field {
        case concertName
        case url
        case additionalNote
    }

    func focusField(_ field: Field) {
        isConcertNameFocused = field == .concertName
        isURLFocused = field == .url
        isAdditionalNoteFocused = field == .additionalNote
    }

    func dismissKeyboard() {
        isConcertNameFocused = false
        isURLFocused = false
        isAdditionalNoteFocused = false
    }

    func handleBack() {
        dismissKeyboard()
        if hasInput {
            isCancelModalPresented = true
        } else {
            onDismiss()
        }
    }

    func submit(shouldAutoRegister: Bool) {
        let url = trimmed(urlText)
        let note = trimmed(additionalNote)
        store.send(.submit(
            title: trimmed(concertName),
            url: url.isEmpty ? nil : url,
            shouldAutoRegister: shouldAutoRegister,
            requestContent: note.isEmpty ? nil : note
        ))
    }
}

// MARK: - Constants

private extension ConcertRequestView {
    enum Constants {
        static let concertNameMaxLength = 50
        static let additionalNoteMinHeight: CGFloat = 248
        /// 버튼 영역(상단 16 + 높이 52) + 추가작성과의 간격 20
        static let scrollBottomPadding: CGFloat = 16 + 52 + 20
    }
}

// MARK: - Literals

private extension ConcertRequestView {
    enum Literals {
        static let navigationTitle = "공연 요청"
        static let headerTitle = "필요한 공연 정보를 요청하면\n빠르게 등록까지 도와드려요"
        static let headerSubtitle = "지난 공연은 관심 콘서트에 추가할 수 없어요"
        static let concertNameTitle = "공연 명"
        static let concertNamePlaceholder = "공연 명을 입력해주세요"
        static let urlTitle = "URL"
        static let urlPlaceholder = "공연 정보를 확인할 수 있는 URL을 추가해주세요"
        static let additionalNoteTitle = "추가 작성"
        static let additionalNotePlaceholder = "아티스트 명이나 공연 일자 적어주면 더 빠르게 등록되어요!"
        static let required = "필수"
        static let optional = "선택"
        static let submit = "요청하기"
        static let cancelMessage = "공연 요청을 그만 두시나요?\n언제든 다시 지정할 수 있어요."
        static let cancelConfirm = "지금은 그만할래요"
        static let cancelDismiss = "잘못 눌렀어요"
        static let failureToast = "요청 중 오류가 발생했어요\n다시 시도해주세요"
    }
}

// MARK: - Preview

#Preview("빈 폼") {
    ConcertRequestView(onDismiss: {}, onRequestSuccess: {})
}

#Preview("공연명 입력") {
    ConcertRequestView(
        concertName: "수만 입력하면 이렇게 다음 버튼 활성화가 됩니다."
    )
}

#Preview("바텀시트") {
    ConcertRequestView(
        concertName: "수만 입력하면 이렇게 다음 버튼 활성화가 됩니다.",
        isBottomSheetPresented: true
    )
}

#Preview("취소 모달") {
    ConcertRequestView(
        concertName: "테스트 공연",
        isCancelModalPresented: true
    )
}
