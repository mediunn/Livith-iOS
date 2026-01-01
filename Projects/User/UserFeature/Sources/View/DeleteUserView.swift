//
//  DeleteUserView.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct DeleteUserView: View {

    // MARK: - Property

    @State private var keyboardHeight: CGFloat = 0
    @State private var isConfirmed: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var showConfirmSheet: Bool = false
    @State private var showErrorToast: Bool = false
    @State private var errorMessage: String = ""

    @ObservedObject private var store: DeleteUserStore

    var onDismiss: (() -> Void)?

    // MARK: - LifeCycle

    init(store: DeleteUserStore, onDismiss: (() -> Void)? = nil) {
        self._store = ObservedObject(wrappedValue: store)
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                navigationBar
                    .padding(.top, 20)
                    .padding(.horizontal, 16)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            titleSection
                                .padding(.top, 30)

                            reasonList
                                .padding(.top, 20)
                                .padding(.bottom, 30)

                            Spacer(minLength: 0)

                            confirmButton
                                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 20 : 50)
                                .id(ScrollID.confirmButton)
                        }
                        .padding(.horizontal, 16)
                    }
                    .onChange(of: isTextFieldFocused) { _, isFocused in
                        if isFocused {
                            Task {
                                try? await Task.sleep(for: .milliseconds(300))
                                withAnimation {
                                    proxy.scrollTo(ScrollID.confirmButton, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.livithColor(.black100))
            .ignoresSafeArea(.all, edges: .bottom)
            .onTapGesture { isTextFieldFocused = false }
            .onReceive(Keyboard.heightPublisher) { height in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = height
                }
            }
            .onChange(of: showConfirmSheet) { _, isShowing in
                if !isShowing {
                    isConfirmed = false
                }
            }
            .onChange(of: store.state.deleteUserResult) { _, result in
                switch result {
                case .idle:
                    break
                case .success:
                    NotificationCenter.default.post(
                        name: .reloginRequired,
                        object: nil,
                        userInfo: ["toastMessage": Literals.deleteSuccessMessage]
                    )
                case .failure(let message):
                    errorMessage = message
                    showErrorToast = true
                }
            }
            .livithToast(isPresented: $showErrorToast, type: .failure, message: errorMessage, position: .safeAreaTop)
            .overlay {
                customFilterSheet.ignoresSafeArea()
            }

            
        }
    }
}

// MARK: - UIComponents

private extension DeleteUserView {
    var customFilterSheet: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(showConfirmSheet ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    showConfirmSheet = false
                }
                .allowsHitTesting(showConfirmSheet)
                .animation(.easeInOut(duration: 0.3), value: showConfirmSheet)
            
            VStack(spacing: 0) {
                DeleteUserConfirmBottomSheet(
                    isPresented: $showConfirmSheet,
                    isConfirmed: $isConfirmed,
                    onCancel: {
                        showConfirmSheet = false
                    },
                    onConfirm: {
                        showConfirmSheet = false
                        store.send(.deleteUser)
                    }
                )
            }
            .frame(maxWidth: .infinity)
            .background(Color.livithColor(.black90))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16
                )
            )
            .offset(y: showConfirmSheet ? 0 : UIScreen.main.bounds.height)
            .animation(.easeInOut(duration: 0.3), value: showConfirmSheet)
        }
    }
    
    var navigationBar: some View {
        HStack {
            Button {
                onDismiss?()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .foregroundColor(.livithColor(.white100))
            }

            Spacer()
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.title)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text(Literals.subtitle)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var reasonList: some View {
        VStack(spacing: 10) {
            ForEach(DeleteUserReason.allCases, id: \.self) { reason in
                reasonRow(reason)
            }
        }
    }

    func reasonRow(_ reason: DeleteUserReason) -> some View {
        let isSelected = store.state.selectedReasons.contains(reason)
        let isOther = reason == .other
        let showTextField = isOther && isSelected

        return VStack(spacing: 0) {
            Button {
                store.send(.toggleReason(reason))
            } label: {
                HStack(spacing: 12) {
                    checkboxImage(isSelected: isSelected)

                    Text(reason.rawValue)
                        .notosans(.body2Medium)
                        .foregroundStyle(Color.livithColor(.white100))

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
            }

            if showTextField {
                otherReasonTextField
                    .padding(.horizontal, 14)
                    .padding(.bottom, 16)
            }
        }
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.3), value: showTextField)
    }

    func checkboxImage(isSelected: Bool) -> some View {
        Image.livithIcon(isSelected ? .checkboxFillEnabled : .checkboxFillDefault)
            .resizable()
            .frame(width: 24, height: 24)
    }

    var otherReasonTextField: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topLeading) {
                if store.state.otherReasonText.isEmpty {
                    Text(Literals.textFieldPlaceholder)
                        .notosans(.body3Medium)
                        .foregroundStyle(Color.livithColor(.black50))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: Binding(
                    get: { store.state.otherReasonText },
                    set: { store.send(.updateOtherReasonText($0)) }
                ))
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.livithColor(.white100))
                .notosans(.body4Medium)
                .focused($isTextFieldFocused)
            }
            .padding(12)
            .frame(height: 206)
            .background(Color.livithColor(.black80))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.livithColor(.black50), lineWidth: isTextFieldFocused ? 1 : 0)
            )

            Text("\(store.otherReasonTextCount)/200")
                .notosans(.caption1Regular)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.trailing, 16)
                .padding(.bottom, 12)
        }
    }

    var confirmButton: some View {
        Button {
            isTextFieldFocused = false
            showConfirmSheet = true
        } label: {
            HStack(spacing: 8) {
                Text(Literals.confirmButtonText)
                    .notosans(.body2Medium)
                    .foregroundStyle(
                        store.isConfirmButtonEnabled
                            ? Color.livithColor(.black100)
                            : Color.livithColor(.black30)
                    )
            }
            .animation(.easeInOut(duration: 0.2), value: store.state.selectedReasons)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                store.isConfirmButtonEnabled
                    ? Color.livithColor(.yellow30)
                    : Color.livithColor(.black50)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!store.isConfirmButtonEnabled || store.state.isLoading)
    }
}

// MARK: - Constants

private extension DeleteUserView {
    enum ScrollID {
        static let confirmButton = "confirmButton"
    }

    enum Literals {
        static let title = "정말 탈퇴하시겠어요?"
        static let subtitle = "탈퇴 이유를 알려주시면,\n서비스 개선에 반영해 더 좋은 서비스로 찾아뵐게요"
        static let textFieldPlaceholder = "10자 이상의 사유를 작성해주세요"
        static let confirmButtonText = "탈퇴하기"
        static let deleteSuccessMessage = "탈퇴가 완료되었어요.\n더 좋은 서비스로 다시 만나요!"
    }
}

#Preview {
    DeleteUserView(store: DeleteUserStore())
}
