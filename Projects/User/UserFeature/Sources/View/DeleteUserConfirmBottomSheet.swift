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
        LivithBottomSheet {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                    .padding(.horizontal, 16)
                    .padding(.top, 30)
                    .padding(.bottom, 16)

                ZStack(alignment: .top) {
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

                    LinearGradient(
                        colors: [
                            Color.livithColor(.black90),
                            Color.livithColor(.black90).opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 16)
                    .allowsHitTesting(false)
                }

                actionButtons
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - UIComponents

private extension DeleteUserConfirmBottomSheet {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.title)
                .notosans(.headSemibold)
                .foregroundStyle(Color.livithColor(.white100))

            Text(Literals.subtitle)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
        }
    }

    var noticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Literals.noticeItems, id: \.self) { item in
                noticeItem(item)
            }
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

                Text(Literals.confirmCheckboxText)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))

                Spacer()
            }
        }
    }

    var actionButtons: some View {
        HStack(spacing: 12) {
            LivithButton(Literals.cancelButtonText, variant: .secondary) {
                onCancel()
            }

            LivithButton(Literals.confirmButtonText, variant: .pink) {
                onConfirm()
            }
            .disabled(!isConfirmed)
        }
    }
}

// MARK: - Literals

private extension DeleteUserConfirmBottomSheet {
    enum Literals {
        static let title = "정말 탈퇴하시겠어요?"
        static let subtitle = "같은 아이디는 7일 이후 다시 가입할 수 있어요"
        static let noticeItems = [
            "회원 탈퇴 시 관심 콘서트, 닉네임 등 개인 정보는 모두 삭제됩니다.",
            "탈퇴한 아이디로 작성한 댓글은 삭제되지 않고 유지됩니다.",
            "탈퇴 후 즉시 재가입을 통해 서비스에 혼란을 초래하는 경우를 방지하기 위해 탈퇴 후 7일 간 동일 아이디로 가입이 제한됩니다.",
            "탈퇴 후 7일 간 가입 제한을 위해 계정 정보를 보관합니다."
        ]
        static let confirmCheckboxText = "위 내용을 모두 확인했습니다."
        static let cancelButtonText = "취소할래요"
        static let confirmButtonText = "탈퇴할래요"
    }
}
