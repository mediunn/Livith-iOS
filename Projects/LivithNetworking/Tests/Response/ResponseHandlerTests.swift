//
//  ResponseHandlerTests.swift
//  LivithNetworkingTests
//
//  Created by 김진웅 on 5/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import LivithNetworking

@Suite("ResponseHandler")
struct ResponseHandlerTests {
    @Test("성공 응답은 wrapper data를 decode해야 한다")
    func 성공_응답은_wrapper_data를_decode해야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": { "value": "livith" }
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 200)

        let value = try sut.handle(ResponseBody.self, data: data, response: response)

        #expect(value == ResponseBody(value: "livith"))
    }

    @Test("성공 응답에서 EmptyResponse는 data가 없어도 성공해야 한다")
    func 성공_응답에서_EmptyResponse는_data가_없어도_성공해야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": null
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 204)

        let value = try sut.handle(EmptyResponse.self, data: data, response: response)

        #expect(value == EmptyResponse())
    }

    @Test("성공 응답에서 일반 타입의 data가 없으면 noData를 던져야 한다")
    func 성공_응답에서_일반_타입의_data가_없으면_noData를_던져야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": null
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 200)

        do {
            _ = try sut.handle(ResponseBody.self, data: data, response: response)
            #expect(Bool(false))
        } catch .noData {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("실패 status code는 서버 message와 함께 invalidStatusCode를 던져야 한다")
    func 실패_status_code는_서버_message와_함께_invalidStatusCode를_던져야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 404,
            "error": "NOT_FOUND",
            "message": "not found",
            "data": null
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 404)

        do {
            _ = try sut.handle(ResponseBody.self, data: data, response: response)
            #expect(Bool(false))
        } catch .invalidStatusCode(let statusCode, let message) {
            #expect(statusCode == 404)
            #expect(message == "not found")
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("실패 status code의 body decode에 실패하면 message는 nil이어야 한다")
    func 실패_status_code의_body_decode에_실패하면_message는_nil이어야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("not-json")
        let response = try HTTPTestResponseFactory().response(statusCode: 500)

        do {
            _ = try sut.handle(ResponseBody.self, data: data, response: response)
            #expect(Bool(false))
        } catch .invalidStatusCode(let statusCode, let message) {
            #expect(statusCode == 500)
            #expect(message == nil)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("성공 응답 body decode에 실패하면 decodingFailed를 던져야 한다")
    func 성공_응답_body_decode에_실패하면_decodingFailed를_던져야_한다() throws {
        let sut = ResponseHandler()
        let data = try HTTPTestResponseFactory().data("not-json")
        let response = try HTTPTestResponseFactory().response(statusCode: 200)

        do {
            _ = try sut.handle(ResponseBody.self, data: data, response: response)
            #expect(Bool(false))
        } catch .decodingFailed {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("주입한 decoder를 wrapper decoding에 사용해야 한다")
    func 주입한_decoder를_wrapper_decoding에_사용해야_한다() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let sut = ResponseHandler(decoder: decoder)
        let data = try HTTPTestResponseFactory().data("""
        {
            "statusCode": 200,
            "error": null,
            "message": "success",
            "data": { "client_name": "livith" }
        }
        """)
        let response = try HTTPTestResponseFactory().response(statusCode: 200)

        let value = try sut.handle(StrategyBody.self, data: data, response: response)

        #expect(value == StrategyBody(clientName: "livith"))
    }
}

private extension ResponseHandlerTests {
    struct ResponseBody: Decodable, Equatable {
        let value: String
    }

    struct StrategyBody: Decodable, Equatable {
        let clientName: String
    }
}
