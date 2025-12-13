//
//  DeleteUserConfirmBottomSheet.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct DeleteUserConfirmBottomSheet: View {

    // MARK: - Property

    @Binding var isPresented: Bool
    @Binding var isConfirmed: Bool

    var onCancel: () -> Void
    var onConfirm: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            handleBar
                .padding(.top, 10)
                .padding(.bottom, 24)

            titleSection
                .padding(.horizontal, 16)

            ScrollView {
                VStack(alignment: .leading) {
                    noticeSection
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    confirmCheckbox
                        .padding(.horizontal, 45)
                        .padding(.vertical, 20)
                }
            }
            .frame(height: 204)

            actionButtons
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 24)
        }
    }
}

// MARK: - UIComponents

private extension DeleteUserConfirmBottomSheet {
    var handleBar: some View {
        Rectangle()
            .fill(Color.livithColor(.black80))
            .frame(width: 60, height: 6)
            .cornerRadius(3)
            .frame(maxWidth: .infinity)
    }

    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("정말 탈퇴하시겠어요?")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text("같은 아이디는 7일 이후 다시 가입할 수 있어요")
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var noticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            noticeItem("회원 탈퇴 시 관심 콘서트, 닉네임 등 개인 정보는 모두 삭제됩니다.")
            noticeItem("탈퇴한 아이디로 작성한 댓글은 삭제되지 않고 유지됩니다.")
            noticeItem("탈퇴 후 즉시 재가입을 통해 서비스에 혼란을 초래하는 경우를 방지하기 위해 탈퇴 후 7일 간 동일 아이디로 가입이 제한됩니다.")
            noticeItem("탈퇴 후 7일 간 가입 제한을 위해 계정 정보를 보관합니다.")
        }
        .padding(16)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func noticeItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("• " + text)
                .notosans(.body3Medium)
                .foregroundStyle(Color.livithColor(.black30))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var confirmCheckbox: some View {
        Button {
            isConfirmed.toggle()
        } label: {
            HStack(spacing: 12) {
                Image.livithIcon(isConfirmed ? .checkboxFillEnabled : .checkboxFillDefault)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("위 내용을 모두 확인했습니다.")
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))

                Spacer()
            }
        }
    }

    var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                onCancel()
            } label: {
                Text("취소할래요")
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.livithColor(.black80))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Button {
                onConfirm()
            } label: {
                Text("탈퇴할래요")
                    .notosans(.body3Semibold)
                    .foregroundStyle(
                        isConfirmed
                            ? Color.livithColor(.black100)
                            : Color.livithColor(.black30)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isConfirmed)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isConfirmed
                        ? Color.livithColor(.transition)
                            : Color.livithColor(.black50)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .disabled(!isConfirmed)
        }
    }
}
