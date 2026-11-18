import Testing

import Domain

@Suite("가입 세션")
struct SignupSessionTests {
    @Test("필수 약관에 동의하기 전에는 제출 정보를 만들 수 없다")
    func requiresTerms() throws {
        var session = makeSession()
        let nickname = try Nickname("라이빗")
        session.recordTermsAgreement(.init(termsOfService: true, privacy: false, marketing: true))
        session.changeNickname(to: nickname)
        session.confirmNickname(nickname)

        #expect(throws: AuthError.requiredTermsNotAgreed) {
            try session.makeSignupInfo(preferredArtistList: [])
        }
    }

    @Test("닉네임을 바꾸면 이전 닉네임에 대한 확인을 반영하지 않는다")
    func invalidatesConfirmationWhenNicknameChanges() throws {
        var session = makeSession()
        let previousNickname = try Nickname("라이빗")
        let nickname = try Nickname("새닉네임")
        session.recordTermsAgreement(.init(termsOfService: true, privacy: true, marketing: false))
        session.changeNickname(to: previousNickname)
        session.confirmNickname(previousNickname)
        session.changeNickname(to: nickname)
        session.confirmNickname(previousNickname)

        #expect(throws: AuthError.nicknameNotConfirmed) {
            try session.makeSignupInfo(preferredArtistList: [])
        }
    }

    @Test("약관 동의와 현재 닉네임 확인을 마치면 제출 정보를 만들 수 있다")
    func buildsSignupInfoForConfirmedNickname() throws {
        var session = makeSession()
        let nickname = try Nickname("라이빗")
        session.recordTermsAgreement(.init(termsOfService: true, privacy: true, marketing: false))
        session.changeNickname(to: nickname)
        session.confirmNickname(nickname)
        session.selectPreferredGenres([.init(id: 7, name: "ROCK_METAL", imageURL: nil)])

        let signup = try session.makeSignupInfo(preferredArtistList: [])

        #expect(signup.nickname == nickname)
        #expect(signup.preferredGenreIDList == [7])
        #expect(signup.isMarketingAgreed == false)
    }

    private func makeSession() -> SignupSession {
        SignupSession(tempUser: TempUser(provider: .kakao, providerID: "test", email: nil))
    }
}
