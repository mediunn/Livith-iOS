//
//  KeychainTokenStoreTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/11/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("KeychainTokenStore")
struct KeychainTokenStoreTests {
    @Test("save 후 fetch는 동일한 Token을 반환해야 한다")
    func save_후_fetch는_동일한_Token을_반환해야_한다() async throws {
        let box = KeychainStorageBox()
        let sut = makeSUT(box: box)
        let token = makeToken()

        try await sut.save(token)
        let fetchedToken = try await sut.fetch()

        #expect(fetchedToken == token)
    }

    @Test("remove 후 fetch는 noToken을 던져야 한다")
    func remove_후_fetch는_noToken을_던져야_한다() async throws {
        let box = KeychainStorageBox()
        let sut = makeSUT(box: box)

        try await sut.save(makeToken())
        try await sut.remove()

        do {
            _ = try await sut.fetch()
            #expect(Bool(false))
        } catch .noToken {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("item이 없는 상태의 remove는 성공해야 한다")
    func item이_없는_상태의_remove는_성공해야_한다() async throws {
        let box = KeychainStorageBox()
        let sut = makeSUT(box: box)

        try await sut.remove()
    }

    @Test("payload decoding 실패는 decodingFailed를 던져야 한다")
    func payload_decoding_실패는_decodingFailed를_던져야_한다() async throws {
        let box = KeychainStorageBox(data: Data("invalid".utf8))
        let sut = makeSUT(box: box)

        do {
            _ = try await sut.fetch()
            #expect(Bool(false))
        } catch .decodingFailed {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Keychain save 실패는 saveFailed로 매핑해야 한다")
    func Keychain_save_실패는_saveFailed로_매핑해야_한다() async throws {
        let box = KeychainStorageBox(saveError: .unexpectedStatus(-1))
        let sut = makeSUT(box: box)

        do {
            try await sut.save(makeToken())
            #expect(Bool(false))
        } catch .saveFailed {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Keychain load itemNotFound는 noToken으로 매핑해야 한다")
    func Keychain_load_itemNotFound는_noToken으로_매핑해야_한다() async throws {
        let box = KeychainStorageBox(loadError: .itemNotFound)
        let sut = makeSUT(box: box)

        do {
            _ = try await sut.fetch()
            #expect(Bool(false))
        } catch .noToken {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Keychain load 실패는 loadFailed로 매핑해야 한다")
    func Keychain_load_실패는_loadFailed로_매핑해야_한다() async throws {
        let box = KeychainStorageBox(loadError: .unexpectedStatus(-1))
        let sut = makeSUT(box: box)

        do {
            _ = try await sut.fetch()
            #expect(Bool(false))
        } catch .loadFailed {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Keychain delete 실패는 deleteFailed로 매핑해야 한다")
    func Keychain_delete_실패는_deleteFailed로_매핑해야_한다() async throws {
        let box = KeychainStorageBox(deleteError: .unexpectedStatus(-1))
        let sut = makeSUT(box: box)

        do {
            try await sut.remove()
            #expect(Bool(false))
        } catch .deleteFailed {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("isRefreshTokenExpired는 만료된 토큰이면 true를 반환해야 한다")
    func isRefreshTokenExpired는_만료된_토큰이면_true를_반환해야_한다() async throws {
        let box = KeychainStorageBox()
        let policy = TokenExpirationPolicy(refreshTokenLifetime: 10)
        let sut = makeSUT(box: box, expirationPolicy: policy)
        let token = makeToken(issuedAt: .now.addingTimeInterval(-11))

        try await sut.save(token)

        #expect(await sut.isRefreshTokenExpired())
    }

    @Test("isRefreshTokenExpired는 만료되지 않은 토큰이면 false를 반환해야 한다")
    func isRefreshTokenExpired는_만료되지_않은_토큰이면_false를_반환해야_한다() async throws {
        let box = KeychainStorageBox()
        let policy = TokenExpirationPolicy(refreshTokenLifetime: 10)
        let sut = makeSUT(box: box, expirationPolicy: policy)
        let token = makeToken(issuedAt: .now)

        try await sut.save(token)

        #expect(!(await sut.isRefreshTokenExpired()))
    }

    @Test("isRefreshTokenExpired는 fetch 실패 시 true를 반환해야 한다")
    func isRefreshTokenExpired는_fetch_실패_시_true를_반환해야_한다() async {
        let box = KeychainStorageBox(loadError: .unexpectedStatus(-1))
        let sut = makeSUT(box: box)

        #expect(await sut.isRefreshTokenExpired())
    }
}

private func makeSUT(
    box: KeychainStorageBox,
    expirationPolicy: TokenExpirationPolicy = .default
) -> KeychainTokenStore {
    KeychainTokenStore(
        service: "test.service",
        account: "test.account",
        expirationPolicy: expirationPolicy,
        keychainStorage: box
    )
}

private func makeToken(
    issuedAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> Token {
    Token(
        accessToken: "access",
        refreshToken: "refresh",
        refreshTokenIssuedAt: issuedAt
    )
}

private final class KeychainStorageBox: KeychainStorage, @unchecked Sendable {
    var data: Data?
    let saveError: KeychainStorageError?
    let loadError: KeychainStorageError?
    let deleteError: KeychainStorageError?

    init(
        data: Data? = nil,
        saveError: KeychainStorageError? = nil,
        loadError: KeychainStorageError? = nil,
        deleteError: KeychainStorageError? = nil
    ) {
        self.data = data
        self.saveError = saveError
        self.loadError = loadError
        self.deleteError = deleteError
    }

    func save(
        _ data: Data,
        service: String,
        account: String
    ) throws(KeychainStorageError) {
        if let saveError {
            throw saveError
        }

        self.data = data
    }

    func load(
        service: String,
        account: String
    ) throws(KeychainStorageError) -> Data {
        if let loadError {
            throw loadError
        }

        guard let data else {
            throw KeychainStorageError.itemNotFound
        }

        return data
    }

    func delete(
        service: String,
        account: String
    ) throws(KeychainStorageError) {
        if let deleteError {
            throw deleteError
        }

        data = nil
    }
}
