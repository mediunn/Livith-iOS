//
//  HTTPMethodTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import LivithNetworking

@Suite("HTTPMethod")
struct HTTPMethodTests {
    @Test("HTTP method raw value는 대문자 문자열이어야 한다")
    func HTTP_method_raw_value는_대문자_문자열이어야_한다() {
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.patch.rawValue == "PATCH")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
    }
}
