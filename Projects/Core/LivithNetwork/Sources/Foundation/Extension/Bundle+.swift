//
//  Bundle+.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public extension Bundle {
    static let apiVersion: String = {
        #if DEBUG
        return "v5"
        #else
        return "v4"
        #endif
    }()

    static let baseURL: URL = {
        guard let url = URL(string: "\(baseURLString)/api/\(apiVersion)") else {
            fatalError("BASE_URL에서 추출한 문자열을 URL로 변환할 수 없습니다.")
        }

        return url
    }()
}

private extension Bundle {
    static func object(dictionaryKey: String) -> String {
        let networkBundle = Bundle(identifier: "com.youz2me.livith.livithnetwork") ?? Bundle.main

        guard let object = networkBundle.object(forInfoDictionaryKey: dictionaryKey) as? String else {
            fatalError("\(dictionaryKey)을 찾을 수 없습니다.")
        }
        
        return object
    }
}

private extension Bundle {
    static let baseURLString: String = object(dictionaryKey: "BASE_URL")
}
