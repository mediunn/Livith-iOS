//
//  NicknameEditStoreTests.swift
//  NicknameEditFeatureTests
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

import DIContainer
import Domain
@testable import NicknameEditFeature

// MARK: - Mock Repositories

final class MockAuthRepository: AuthRepository {
    var checkNicknameResult: Result<Bool, AuthError> = .success(true)
    var signupResult: Result<Void, AuthError> = .success(())

    var checkNicknameCallCount = 0
    var signupCallCount = 0
    var lastCheckedNickname: String?
    var lastSignupNickname: String?

    func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool {
        checkNicknameCallCount += 1
        lastCheckedNickname = nickname
        switch checkNicknameResult {
        case .success(let isAvailable):
            return isAvailable
        case .failure(let error):
            throw error
        }
    }

    func signup(tempUser: TempUser, marketingConsent: Bool, nickname: String) async throws(AuthError) {
        signupCallCount += 1
        lastSignupNickname = nickname
        switch signupResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func withdraw(reason: String) async throws(AuthError) {}
    func logout() async throws(AuthError) {}
    func kakaoLogin() async throws(AuthError) -> LoginStatus { .existingUser(nickname: "test") }
    func appleLogin() async throws(AuthError) -> LoginStatus { .existingUser(nickname: "test") }
    func fetchLastLoginPlatform() async throws(AuthError) -> SocialLoginProvider { .kakao }
}

final class MockUserRepository: UserRepository {
    var updateNicknameResult: Result<Void, UserError> = .success(())

    var updateNicknameCallCount = 0
    var lastUpdatedNickname: String?

    func updateNickname(_ nickname: String) async throws(UserError) {
        updateNicknameCallCount += 1
        lastUpdatedNickname = nickname
        switch updateNicknameResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func fetchUser() async throws(UserError) -> User {
        User(
            id: 1,
            interestConcertID: nil,
            provider: "kakao",
            providerID: "123",
            email: nil,
            nickname: "test",
            marketingConsent: false
        )
    }

    func fetchInterestedConcert() async throws(UserError) -> Concert? { nil }

    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        Concert(
            id: 1,
            title: "테스트 콘서트",
            artist: "테스트 아티스트",
            status: .ongoing,
            daysLeft: 10,
            startDate: Date(),
            endDate: Date(),
            posterURL: URL(string: "https://example.com/poster.jpg")!,
            venue: "테스트 장소",
            ticketSite: nil,
            ticketURL: nil,
            introduction: "테스트 소개",
            label: nil
        )
    }

    func deleteInterestedConcert() async throws(UserError) {}
}

// MARK: - Tests

@Suite("NicknameEditStore 테스트")
@MainActor
struct NicknameEditStoreTests {
    private let mockAuthRepository = MockAuthRepository()
    private let mockUserRepository = MockUserRepository()

    init() {
        DIContainer.shared.register(mockAuthRepository, for: AuthRepository.self)
        DIContainer.shared.register(mockUserRepository, for: UserRepository.self)
    }

    // MARK: - Nickname Format Validation Tests

    @Test("빈 닉네임은 idle 상태여야 한다")
    func emptyNicknameShouldBeIdle() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("")
        #expect(sut.state.validationState == .idle)
    }

    @Test("유효한 한글 닉네임은 valid 상태여야 한다")
    func validKoreanNicknameShouldBeValid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트유저")
        #expect(sut.state.validationState == .valid)
    }

    @Test("유효한 영문 닉네임은 valid 상태여야 한다")
    func validEnglishNicknameShouldBeValid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("TestUser")
        #expect(sut.state.validationState == .valid)
    }

    @Test("유효한 숫자 닉네임은 valid 상태여야 한다")
    func validNumberNicknameShouldBeValid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("1234567890")
        #expect(sut.state.validationState == .valid)
    }

    @Test("유효한 혼합 닉네임은 valid 상태여야 한다")
    func validMixedNicknameShouldBeValid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트User1")
        #expect(sut.state.validationState == .valid)
    }

    @Test("11자 이상 닉네임은 invalid 상태여야 한다")
    func tooLongNicknameShouldBeInvalid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("가나다라마바사아자차카")
        #expect(sut.state.validationState == .invalid)
    }

    @Test("특수문자 포함 닉네임은 invalid 상태여야 한다")
    func specialCharacterNicknameShouldBeInvalid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트!")
        #expect(sut.state.validationState == .invalid)
    }

    @Test("공백 포함 닉네임은 invalid 상태여야 한다")
    func whitespaceNicknameShouldBeInvalid() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트 유저")
        #expect(sut.state.validationState == .invalid)
    }

    // MARK: - Duplicate Check Tests

    @Test("중복 체크 시작하면 checking 상태여야 한다")
    func duplicateCheckShouldStartWithChecking() {
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")
        sut.checkDuplicate()
        #expect(sut.state.validationState == .checking)
    }

    @Test("닉네임 사용 가능하면 available 상태여야 한다")
    func availableNicknameShouldBeAvailable() async {
        mockAuthRepository.checkNicknameResult = .success(true)
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")

        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.validationState == .available)
        #expect(mockAuthRepository.checkNicknameCallCount == 1)
        #expect(mockAuthRepository.lastCheckedNickname == "테스트")
    }

    @Test("닉네임 중복이면 duplicate 상태여야 한다")
    func duplicateNicknameShouldBeDuplicate() async {
        mockAuthRepository.checkNicknameResult = .success(false)
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("중복닉네임")

        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.validationState == .duplicate)
    }

    @Test("중복 체크 에러 발생하면 duplicate 상태여야 한다")
    func duplicateCheckErrorShouldBeDuplicate() async {
        mockAuthRepository.checkNicknameResult = .failure(.noConnection)
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")

        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.validationState == .duplicate)
    }

    // MARK: - Submit Tests (Signup)

    @Test("signup 제출 성공하면 success 상태여야 한다")
    func signupSuccessShouldBeSuccess() async {
        mockAuthRepository.signupResult = .success(())
        let tempUser = TempUser(provider: .kakao, providerID: "123", email: "test@test.com")
        let sut = NicknameEditStore(config: .signup(marketingConsent: true, tempUser: tempUser))
        sut.updateNickname("테스트")

        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.submitResult == .success)
        #expect(sut.state.isSubmitting == false)
        #expect(mockAuthRepository.signupCallCount == 1)
        #expect(mockAuthRepository.lastSignupNickname == "테스트")
    }

    @Test("signup 제출 실패하면 failure 상태여야 한다")
    func signupFailureShouldBeFailure() async {
        mockAuthRepository.signupResult = .failure(.serverError)
        let tempUser = TempUser(provider: .kakao, providerID: "123", email: nil)
        let sut = NicknameEditStore(config: .signup(marketingConsent: false, tempUser: tempUser))
        sut.updateNickname("테스트")

        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        if case .failure = sut.state.submitResult {
            #expect(true)
        } else {
            Issue.record("Expected failure state")
        }
        #expect(sut.state.isSubmitting == false)
    }

    // MARK: - Submit Tests (Update)

    @Test("update 제출 성공하면 success 상태여야 한다")
    func updateSuccessShouldBeSuccess() async {
        mockUserRepository.updateNicknameResult = .success(())
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("새닉네임")

        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut.state.submitResult == .success)
        #expect(sut.state.isSubmitting == false)
        #expect(mockUserRepository.updateNicknameCallCount == 1)
        #expect(mockUserRepository.lastUpdatedNickname == "새닉네임")
    }

    @Test("update 제출 실패하면 failure 상태여야 한다")
    func updateFailureShouldBeFailure() async {
        mockUserRepository.updateNicknameResult = .failure(.serverError)
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("새닉네임")

        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        if case .failure = sut.state.submitResult {
            #expect(true)
        } else {
            Issue.record("Expected failure state")
        }
        #expect(sut.state.isSubmitting == false)
    }

    // MARK: - Reset Tests

    @Test("submitResult 리셋하면 idle 상태여야 한다")
    func resetSubmitResultShouldBeIdle() {
        let sut = NicknameEditStore(config: .update)
        sut.resetSubmitResult()
        #expect(sut.state.submitResult == .idle)
    }

    @Test("닉네임 변경하면 submitResult가 idle로 리셋되어야 한다")
    func nicknameChangeShouldResetSubmitResult() async {
        mockUserRepository.updateNicknameResult = .success(())
        let sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))
        #expect(sut.state.submitResult == .success)

        sut.updateNickname("새닉네임")

        #expect(sut.state.submitResult == .idle)
    }
}
