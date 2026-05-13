//
//  ETagCacheHandler.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct ETagCacheHandler: Sendable {
    private let store: any ETagCacheStore

    init(store: any ETagCacheStore) {
        self.store = store
    }

    func removeAll() async {
        await store.removeAll()
    }

    func key(
        for request: URLRequest,
        endpoint: NetworkEndpoint
    ) -> String? {
        guard endpoint.etagCacheEnabled,
              endpoint.method == .get,
              let method = request.httpMethod,
              let url = request.url?.absoluteString
        else {
            return nil
        }

        return "\(method) \(url)"
    }

    func apply(
        to request: inout URLRequest,
        key: String?,
        skipsETag: Bool
    ) async {
        guard !skipsETag else {
            request.setValue(nil, forHTTPHeaderField: "If-None-Match")
            return
        }

        guard let key,
              let entry = await store.value(for: key)
        else {
            return
        }

        request.setValue(entry.etag, forHTTPHeaderField: "If-None-Match")
    }

    func handle(
        data: Data,
        response: HTTPURLResponse,
        request: URLRequest,
        key: String?
    ) async -> ETagCacheResult {
        guard let key else {
            return .response(data, response)
        }

        switch response.statusCode {
        case 200:
            await save(data: data, response: response, key: key)
            return .response(data, response)
        case 304:
            guard let entry = await store.value(for: key),
                  let response = cachedResponse(from: response, request: request, entry: entry)
            else {
                return .fallback
            }

            return .response(entry.data, response)
        default:
            return .response(data, response)
        }
    }
}

private extension ETagCacheHandler {
    func save(
        data: Data,
        response: HTTPURLResponse,
        key: String
    ) async {
        guard let etag = response.etag else {
            await store.remove(for: key)
            return
        }

        await store.save(
            ETagCacheEntry(etag: etag, data: data, statusCode: response.statusCode),
            for: key
        )
    }

    func cachedResponse(
        from response: HTTPURLResponse,
        request: URLRequest,
        entry: ETagCacheEntry
    ) -> HTTPURLResponse? {
        guard let url = response.url ?? request.url else { return nil }

        return HTTPURLResponse(
            url: url,
            statusCode: entry.statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}

enum ETagCacheResult {
    case response(Data, HTTPURLResponse)
    case fallback
}

private extension HTTPURLResponse {
    var etag: String? {
        for (key, value) in allHeaderFields {
            guard String(describing: key).caseInsensitiveCompare("ETag") == .orderedSame else {
                continue
            }

            if let value = value as? String, !value.isEmpty {
                return value
            }

            let string = String(describing: value)
            return string.isEmpty ? nil : string
        }

        return nil
    }
}
