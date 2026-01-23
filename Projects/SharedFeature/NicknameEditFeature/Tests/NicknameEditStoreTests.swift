//
//  NicknameEditStoreTests.swift
//  NicknameEditFeatureTests
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import XCTest

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
    func kakaoLogin() async throws(AuthError) -> LoginStatus { .existingUser }
    func appleLogin() async throws(AuthError) -> LoginStatus { .existingUser }
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
        User(id: 1, interestConcertID: nil, provider: "kakao", providerID: "123", email: nil, nickname: "test", marketingConsent: false)
    }

    func fetchInterestedConcert() async throws(UserError) -> Concert? { nil }
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        Concert(id: 1, name: "test", artist: "test", venue: "test", startDate: "2025-01-01", endDate: "2025-01-01", posterURL: nil, ticketOpenDate: nil)
    }
    func deleteInterestedConcert() async throws(UserError) {}
}

// MARK: - Tests

@MainActor
final class NicknameEditStoreTests: XCTestCase {
    private var sut: NicknameEditStore!
    private var mockAuthRepository: MockAuthRepository!
    private var mockUserRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockAuthRepository = MockAuthRepository()
        mockUserRepository = MockUserRepository()

        DIContainer.shared.register(mockAuthRepository, for: AuthRepository.self)
        DIContainer.shared.register(mockUserRepository, for: UserRepository.self)
    }

    override func tearDown() {
        sut = nil
        mockAuthRepository = nil
        mockUserRepository = nil
        super.tearDown()
    }

    // MARK: - Nickname Format Validation Tests

    func test_빈_닉네임은_idle_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("")

        // Then
        XCTAssertEqual(sut.state.validationState, .idle)
    }

    func test_유효한_한글_닉네임은_valid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("테스트유저")

        // Then
        XCTAssertEqual(sut.state.validationState, .valid)
    }

    func test_유효한_영문_닉네임은_valid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("TestUser")

        // Then
        XCTAssertEqual(sut.state.validationState, .valid)
    }

    func test_유효한_숫자_닉네임은_valid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("1234567890")

        // Then
        XCTAssertEqual(sut.state.validationState, .valid)
    }

    func test_유효한_혼합_닉네임은_valid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("테스트User1")

        // Then
        XCTAssertEqual(sut.state.validationState, .valid)
    }

    func test_11자_이상_닉네임은_invalid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("가나다라마바사아자차카")

        // Then
        XCTAssertEqual(sut.state.validationState, .invalid)
    }

    func test_특수문자_포함_닉네임은_invalid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("테스트!")

        // Then
        XCTAssertEqual(sut.state.validationState, .invalid)
    }

    func test_공백_포함_닉네임은_invalid_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.updateNickname("테스트 유저")

        // Then
        XCTAssertEqual(sut.state.validationState, .invalid)
    }

    // MARK: - Duplicate Check Tests

    func test_중복_체크_시작하면_checking_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")

        // When
        sut.checkDuplicate()

        // Then
        XCTAssertEqual(sut.state.validationState, .checking)
    }

    func test_닉네임_사용_가능하면_available_상태여야_한다() async {
        // Given
        mockAuthRepository.checkNicknameResult = .success(true)
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")

        // When
        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertEqual(sut.state.validationState, .available)
        XCTAssertEqual(mockAuthRepository.checkNicknameCallCount, 1)
        XCTAssertEqual(mockAuthRepository.lastCheckedNickname, "테스트")
    }

    func test_닉네임_중복이면_duplicate_상태여야_한다() async {
        // Given
        mockAuthRepository.checkNicknameResult = .success(false)
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("중복닉네임")

        // When
        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertEqual(sut.state.validationState, .duplicate)
    }

    func test_중복_체크_에러_발생하면_duplicate_상태여야_한다() async {
        // Given
        mockAuthRepository.checkNicknameResult = .failure(.networkError)
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")

        // When
        sut.checkDuplicate()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertEqual(sut.state.validationState, .duplicate)
    }

    // MARK: - Submit Tests (Signup)

    func test_signup_제출_성공하면_success_상태여야_한다() async {
        // Given
        mockAuthRepository.signupResult = .success(())
        let tempUser = TempUser(provider: .kakao, providerID: "123", email: "test@test.com")
        sut = NicknameEditStore(config: .signup(marketingConsent: true, tempUser: tempUser))
        sut.updateNickname("테스트")

        // When
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertEqual(sut.state.submitResult, .success)
        XCTAssertFalse(sut.state.isSubmitting)
        XCTAssertEqual(mockAuthRepository.signupCallCount, 1)
        XCTAssertEqual(mockAuthRepository.lastSignupNickname, "테스트")
    }

    func test_signup_제출_실패하면_failure_상태여야_한다() async {
        // Given
        mockAuthRepository.signupResult = .failure(.serverError)
        let tempUser = TempUser(provider: .kakao, providerID: "123", email: nil)
        sut = NicknameEditStore(config: .signup(marketingConsent: false, tempUser: tempUser))
        sut.updateNickname("테스트")

        // When
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        if case .failure = sut.state.submitResult {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failure state")
        }
        XCTAssertFalse(sut.state.isSubmitting)
    }

    // MARK: - Submit Tests (Update)

    func test_update_제출_성공하면_success_상태여야_한다() async {
        // Given
        mockUserRepository.updateNicknameResult = .success(())
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("새닉네임")

        // When
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        XCTAssertEqual(sut.state.submitResult, .success)
        XCTAssertFalse(sut.state.isSubmitting)
        XCTAssertEqual(mockUserRepository.updateNicknameCallCount, 1)
        XCTAssertEqual(mockUserRepository.lastUpdatedNickname, "새닉네임")
    }

    func test_update_제출_실패하면_failure_상태여야_한다() async {
        // Given
        mockUserRepository.updateNicknameResult = .failure(.serverError)
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("새닉네임")

        // When
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        if case .failure = sut.state.submitResult {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failure state")
        }
        XCTAssertFalse(sut.state.isSubmitting)
    }

    // MARK: - Reset Tests

    func test_submitResult_리셋하면_idle_상태여야_한다() {
        // Given
        sut = NicknameEditStore(config: .update)

        // When
        sut.resetSubmitResult()

        // Then
        XCTAssertEqual(sut.state.submitResult, .idle)
    }

    func test_닉네임_변경하면_submitResult가_idle로_리셋되어야_한다() async {
        // Given
        mockUserRepository.updateNicknameResult = .success(())
        sut = NicknameEditStore(config: .update)
        sut.updateNickname("테스트")
        sut.submit()
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(sut.state.submitResult, .success)

        // When
        sut.updateNickname("새닉네임")

        // Then
        XCTAssertEqual(sut.state.submitResult, .idle)
    }
}
