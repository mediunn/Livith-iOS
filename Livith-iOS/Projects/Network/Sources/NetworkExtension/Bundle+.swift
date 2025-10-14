//
//  Bundle+.swift
//  network
//
//  Created by Youjin Lee on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public extension Bundle {
    static let versionedBaseURL: URL = {
        guard let url = URL(string: baseURL + version) else {
            fatalError("BASE_URL에서 추출한 문자열을 URL로 변환할 수 없습니다.")
        }
        
        return url
    }()
}

private extension Bundle {
    static func object(dictionaryKey: String) -> String {
        guard let object = main.object(forInfoDictionaryKey: dictionaryKey) as? String else {
            fatalError("\(dictionaryKey)을 찾을 수 없습니다.")
        }
        
        return object
    }
}

private extension Bundle {
    static let baseURL: String = object(dictionaryKey: "BASE_URL")
    static let version: String = object(dictionaryKey: "CURRENT_VERSION")
}
