//
//  UserView.swift
//  User
//
//  Created by Youjin Lee on 12/2/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

public struct UserView: View {

    // MARK: - Enum

    enum OverlayType: Equatable {
        case none
        case feedbackForm

        var sheetURL: URL? {
            switch self {
            case .feedbackForm:
                return Constant.feedbackFormURL
            default:
                return nil
            }
        }
    }

    // MARK: - Property

    @State private var overlayType: OverlayType = .none
    @State private var showNicknameSuccessToast: Bool = false

    @Binding private var isTabBarHidden: Bool

    @StateObject private var store = UserStore()

    private let onSetting: () -> Void
    private let onNicknameEdit: () -> Void
    private let onGenreSetting: () -> Void
    private let onArtistSetting: () -> Void

    // MARK: - LifeCycle

    public init(
        isTabBarHidden: Binding<Bool>,
        onSetting: @escaping () -> Void,
        onNicknameEdit: @escaping () -> Void,
        onGenreSetting: @escaping () -> Void,
        onArtistSetting: @escaping () -> Void
    ) {
        self._isTabBarHidden = isTabBarHidden
        self.onSetting = onSetting
        self.onNicknameEdit = onNicknameEdit
        self.onGenreSetting = onGenreSetting
        self.onArtistSetting = onArtistSetting
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            settingButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 12)
                .padding(.trailing, 16)

            headerSection
                .padding(.top, 78)
                .padding(.horizontal, 16)

            divideLine
                .padding(.top, 20)
                .padding(.bottom, 20)

            feedbackButton
                .frame(height: 84)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)

            preferenceSection
                .padding(.horizontal, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
        .sheet(isPresented: isSheetPresented) {
            if let url = overlayType.sheetURL {
                SafariView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .livithToast(
            isPresented: $showNicknameSuccessToast,
            type: .success,
            message: Literals.toastSuccess
        )
        .onAppear {
            store.send(.fetchNickname)
        }
    }
}

// MARK: - UIComponents

private extension UserView {
    var settingButton: some View {
        Button(action: onSetting) {
            Image.livithIcon(.settingFill)
                .resizable()
                .frame(width: 36, height: 36)
        }
    }

    var headerSection: some View {
        HStack(alignment: .center) {
            titleText
            Spacer()
            editButton
        }
    }

    var titleText: some View {
        Text.init(
            String(format: Literals.titleFormat, store.state.nickname),
            highlighting: "\(store.state.nickname)",
            color: .livithColor(.white100),
            font: .notosans(.headSemibold)
        )
        .notosans(.headMedium)
        .foregroundStyle(Color.livithColor(.black30))
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }

    var editButton: some View {
        Button(action: onNicknameEdit) {
            Text(Literals.editNickname)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black5))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
        }
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var divideLine: some View {
        Divider()
            .frame(height: 5)
            .background(Color.init(hex: "29303C", opacity: 1.0))
    }

    var feedbackButton: some View {
        Button {
            showFeedbackForm()
        } label: {
            Image.livithImage(.feedback)
                .resizable()
                .scaledToFill()
        }
    }

    var preferenceSection: some View {
        VStack(spacing: 24) {
            genreSection
            artistSection
        }
    }

    var genreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Literals.preferredGenre)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color.livithColor(.white100))

                Spacer()
                
                LivithTextButton(
                    store.state.hasGenreData ? Literals.change : Literals.setup,
                    action: onGenreSetting
                )
            }

            if store.state.hasGenreData {
                genreCards
            } else {
                placeholderText(Literals.genrePlaceholder)
            }
        }
    }

    var artistSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(Literals.preferredArtist)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color.livithColor(.white100))

                Spacer()
                
                LivithTextButton(
                    store.state.hasArtistData ? Literals.change : Literals.setup,
                    action: onArtistSetting
                )
            }

            if store.state.hasArtistData {
                artistCards
            } else {
                placeholderText(Literals.artistPlaceholder)
            }
        }
    }

    func placeholderText(_ text: String) -> some View {
        Text(text)
            .notosans(.body2Medium)
            .foregroundStyle(Color.livithColor(.black80))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }

    var genreCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.state.genres, id: \.self) { genre in
                    PreferenceCard(title: genre)
                }
            }
        }
    }

    var artistCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.state.artists, id: \.self) { artist in
                    PreferenceCard(title: artist)
                }
            }
        }
    }
}

// MARK: - PreferenceCard

private struct PreferenceCard: View {
    let title: String

    var body: some View {
        Text(title)
            .notosans(.body2Semibold)
            .foregroundStyle(Color.livithColor(.white100))
            .frame(width: 108, height: 108)
            .background(Color.livithColor(.black80))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Helper

private extension UserView {
    var isSheetPresented: Binding<Bool> {
        Binding(
            get: { overlayType.sheetURL != nil },
            set: { if !$0 { overlayType = .none } }
        )
    }

    func showFeedbackForm() {
        overlayType = .feedbackForm
    }

    func showNicknameSuccess() {
        showNicknameSuccessToast = true
    }
}

// MARK: - Constants

private extension UserView {
    enum Constant {
        static let feedbackFormURL = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSe-d5MhQrwsRRrk9isYiYVw1afI7a60Xm0IHbxmmAHe8AUiMA/viewform")!
    }

    enum Literals {
        static let titleFormat = "%@님, 반가워요!\n공연 준비 시작해볼까요?"
        static let editNickname = "닉네임 수정"
        static let toastSuccess = "닉네임이 수정되었어요"
        static let preferredGenre = "선호 장르"
        static let preferredArtist = "선호 아티스트"
        static let setup = "설정하기"
        static let change = "변경하기"
        static let genrePlaceholder = "선호 장르를 기반으로\n맞춤 콘서트를 알려드려요"
        static let artistPlaceholder = "선호 아티스트를 기반으로\n맞춤 콘서트를 알려드려요"
    }
}

// MARK: - Preview

#Preview {
    UserView(
        isTabBarHidden: .constant(false),
        onSetting: {},
        onNicknameEdit: {},
        onGenreSetting: {},
        onArtistSetting: {}
    )
}
