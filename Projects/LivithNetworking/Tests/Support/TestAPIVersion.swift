//
//  TestAPIVersion.swift
//  LivithNetworkingTests
//
//  Created by youz2me on 7/20/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// NetworkConfig.apiVersion은 빌드 구성별로 달라지므로 테스트 기대값도 동일 조건으로 계산한다.
enum TestAPIVersion {
    #if DEBUG
    static let path = "api/v7"
    #else
    static let path = "api/v6"
    #endif
}
