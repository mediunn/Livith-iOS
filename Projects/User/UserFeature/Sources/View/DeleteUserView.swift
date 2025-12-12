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

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @ObservedObject private var store = DeleteUserStore()
    
    // MARK: - LifeCycle
    
    init(store: DeleteUserStore = DeleteUserStore()) {
        self.store = store
    }

    // MARK: - Body
    
    public var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .ignoresSafeArea()
                .onTapGesture {
                    isTextFieldFocused = false
                }

            VStack(alignment: .leading, spacing: 0) {
                navigationBar
                    .padding(.top, 20)

                titleSection
                    .padding(.top, 32)

                reasonList
                    .padding(.top, 24)

                if store.state.selectedReasons.contains(.other) {
                    otherReasonTextField
                        .padding(.top, 16)
                }

                Spacer()

                withdrawButton
                    .padding(.bottom, 50)
            }
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: store.state.isSucceed) { _, newValue in
            if newValue {
                // TODO: 로그인 화면으로 이동
            }
        }
    }
}

// MARK: - UIComponents

private extension DeleteUserView {
    var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .foregroundColor(.livithColor(.white100))
            }

            Spacer()
        }
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("정말 탈퇴하시겠어요?")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text("탈퇴 이유를 알려주시면,\n서비스 개선에 반영해 더 좋은 서비스로 찾아뵐게요")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var reasonList: some View {
        VStack(spacing: 12) {
            ForEach(WithdrawalReason.allCases, id: \.self) { reason in
                reasonRow(reason)
            }
        }
    }

    func reasonRow(_ reason: WithdrawalReason) -> some View {
        Button {
            store.send(.toggleReason(reason))
        } label: {
            HStack(spacing: 12) {
                checkboxImage(isSelected: store.state.selectedReasons.contains(reason))

                Text(reason.rawValue)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.livithColor(.black90))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    func checkboxImage(isSelected: Bool) -> some View {
        Image.livithIcon(isSelected ? .checkboxFillEnabled : .checkboxFillDefault)
            .resizable()
            .frame(width: 24, height: 24)
    }

    var otherReasonTextField: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if store.state.otherReasonText.isEmpty {
                    Text("10자 이상의 사유를 작성해주세요")
                        .notosans(.body3Medium)
                        .foregroundStyle(Color.livithColor(.black50))
                        .padding(.top, 4)
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
            .padding(16)
            .frame(height: 120)
            .background(Color.livithColor(.black90))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text("\(store.otherReasonTextCount)/200")
                .notosans(.caption1Regular)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var withdrawButton: some View {
        Button {
            store.send(.withdraw)
        } label: {
            HStack(spacing: 8) {
                Text("탈퇴하기")
                    .notosans(.body2Medium)
                    .foregroundStyle(
                        store.isWithdrawButtonEnabled
                            ? Color.livithColor(.black100)
                            : Color.livithColor(.black30)
                    )

                if store.state.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .livithColor(.black100)))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                store.isWithdrawButtonEnabled
                    ? Color.livithColor(.yellow30)
                    : Color.livithColor(.black50)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(!store.isWithdrawButtonEnabled || store.state.isLoading)
    }
}

#Preview {
    DeleteUserView()
}
