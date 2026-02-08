//
//  MarketingConsentBottomSheet.swift
//  UserFeature
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct MarketingConsentBottomSheet: View {
    @State private var isMarketingChecked: Bool = true

    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            titleSection
                .padding(.top, 20)
                .padding(.horizontal, 20)

            checkboxSection
                .padding(.top, 20)
                .padding(.horizontal, 20)

            buttonSection
                .padding(.top, 30)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - UI Components

private extension MarketingConsentBottomSheet {
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Literals.title)
                .notosans(.headSemibold)
                .foregroundStyle(Color.livithColor(.white100))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(Literals.subtitle)
                .notosans(.body4Regular)
                .foregroundStyle(Color.livithColor(.black50))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var checkboxSection: some View {
        HStack(alignment: .center, spacing: 8) {
            Image.livithIcon(.checkboxLineEnabled)
                .resizable()
                .frame(width: 24, height: 24)

            Text(Literals.marketingConsent)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.black30))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                // TODO: 마케팅 약관 더보기
            } label: {
                Text(Literals.more)
                    .notosans(.caption2Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isMarketingChecked.toggle()
        }
    }

    var buttonSection: some View {
        HStack(spacing: 8) {
            Button {
                onCancel()
            } label: {
                Text(Literals.cancel)
                    .notosans(.body3Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.livithColor(.black80))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            LivithButton(Literals.confirm, variant: .primary) {
                onConfirm()
            }
        }
    }
}

// MARK: - Constants

private extension MarketingConsentBottomSheet {
    enum Literals {
        static let title = "선택한 선호 장르·아티스트를\n바탕으로 공연 정보를 알려드려요"
        static let subtitle = "추천 공연 알림은 정보 수신 동의가 필요해요"
        static let marketingConsent = "마케팅 활용 / 광고성 정보 수신 동의 (선택)"
        static let more = "더보기 >"
        static let cancel = "괜찮아요"
        static let confirm = "알림을 받을래요"
    }
}

#Preview {
    MarketingConsentBottomSheet(
        onConfirm: {},
        onCancel: {}
    )
}
