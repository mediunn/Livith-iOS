//
//  StorageError.swift
//  Persistence
//
//  Created by 김진웅 on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum StorageError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case dataNotFound
    case unknown

    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "값을 인코딩하지 못했습니다."
        case .decodingFailed:
            return "값을 디코딩하지 못했습니다."
        case .dataNotFound:
            return "해당 키에 대한 데이터를 찾을 수 없습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
