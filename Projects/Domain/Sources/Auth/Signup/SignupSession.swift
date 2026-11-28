public struct SignupTermsAgreement: Hashable {
    public let termsOfService: Bool
    public let privacy: Bool
    public let marketing: Bool

    public var hasAgreedToRequiredTerms: Bool {
        termsOfService && privacy
    }

    public init(termsOfService: Bool, privacy: Bool, marketing: Bool) {
        self.termsOfService = termsOfService
        self.privacy = privacy
        self.marketing = marketing
    }
}

public struct SignupSession: Hashable {
    public private(set) var nickname: Nickname?

    private let tempUser: TempUser
    private var terms: SignupTermsAgreement?
    private var confirmedNickname: Nickname?
    private var preferredGenreIDList: [Int] = []

    public init(tempUser: TempUser) {
        self.tempUser = tempUser
    }

    public mutating func recordTermsAgreement(_ agreement: SignupTermsAgreement) {
        terms = agreement
    }

    public mutating func changeNickname(to nickname: Nickname) {
        guard self.nickname != nickname else { return }
        self.nickname = nickname
        confirmedNickname = nil
    }

    public mutating func confirmNickname(_ nickname: Nickname) {
        guard self.nickname == nickname else { return }
        confirmedNickname = nickname
    }

    public mutating func selectPreferredGenres(_ genres: [PreferredGenre]) {
        preferredGenreIDList = genres.map(\.id)
    }

    public func makeSignupInfo(preferredArtistList: [PreferredArtist]) throws(AuthError) -> SignupInfo {
        guard let terms, terms.hasAgreedToRequiredTerms else {
            throw .requiredTermsNotAgreed
        }
        guard let nickname, nickname == confirmedNickname else {
            throw .nicknameNotConfirmed
        }
        return try SignupInfo(
            provider: tempUser.provider,
            providerID: tempUser.providerID,
            email: tempUser.email,
            nickname: nickname,
            isMarketingAgreed: terms.marketing,
            preferredGenreIDList: preferredGenreIDList,
            preferredArtistIDList: preferredArtistList.map(\.id)
        )
    }
}
