//
//  ETagCacheStoreTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("ETag 캐시 저장소")
struct ETagCacheStoreTests {
    @Test("저장한 entry를 key로 조회해야 한다")
    func 저장한_entry를_key로_조회해야_한다() async {
        let sut = MemoryETagCacheStore()
        let data = Data("cached".utf8)
        let entry = ETagCacheEntry(etag: "\"etag\"", data: data, statusCode: 200)

        await sut.save(entry, for: "GET https://api.example.com/concerts")
        let value = await sut.value(for: "GET https://api.example.com/concerts")

        #expect(value?.etag == "\"etag\"")
        #expect(value?.data == data)
        #expect(value?.statusCode == 200)
    }

    @Test("remove는 지정한 key만 삭제해야 한다")
    func remove는_지정한_key만_삭제해야_한다() async {
        let sut = MemoryETagCacheStore()
        let firstEntry = ETagCacheEntry(etag: "\"first\"", data: Data("first".utf8), statusCode: 200)
        let secondEntry = ETagCacheEntry(etag: "\"second\"", data: Data("second".utf8), statusCode: 200)

        await sut.save(firstEntry, for: "GET https://api.example.com/concerts")
        await sut.save(secondEntry, for: "GET https://api.example.com/songs")
        await sut.remove(for: "GET https://api.example.com/concerts")

        let firstValue = await sut.value(for: "GET https://api.example.com/concerts")
        let secondValue = await sut.value(for: "GET https://api.example.com/songs")

        #expect(firstValue == nil)
        #expect(secondValue?.etag == "\"second\"")
    }

    @Test("removeAll은 모든 entry를 삭제해야 한다")
    func removeAll은_모든_entry를_삭제해야_한다() async {
        let sut = MemoryETagCacheStore()
        let firstEntry = ETagCacheEntry(etag: "\"first\"", data: Data("first".utf8), statusCode: 200)
        let secondEntry = ETagCacheEntry(etag: "\"second\"", data: Data("second".utf8), statusCode: 200)

        await sut.save(firstEntry, for: "GET https://api.example.com/concerts")
        await sut.save(secondEntry, for: "GET https://api.example.com/songs")
        await sut.removeAll()

        let firstValue = await sut.value(for: "GET https://api.example.com/concerts")
        let secondValue = await sut.value(for: "GET https://api.example.com/songs")

        #expect(firstValue == nil)
        #expect(secondValue == nil)
    }
}
