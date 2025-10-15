//
//  LoggingMonitor.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Alamofire

public final class LoggingMonitor: EventMonitor {
    public let queue = DispatchQueue(label: "com.livith.networkmonitor")

    public init() {}

    public func requestDidFinish(_ request: Request) {
        guard let urlRequest = request.request else { return }

        print("🚀 [Request] =====================")
        print("URL: \(urlRequest.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
        print("Method: \(urlRequest.httpMethod ?? "HTTP 메서드를 찾을 수 없습니다")")

        if let headers = urlRequest.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }

        if let body = urlRequest.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        print("======================================\n")
    }

    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        guard let httpResponse = response.response else { return }

        switch response.result {
        case .success:
            print("✅ [Response] ====================")
            print("URL: \(httpResponse.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
            print("Status Code: \(httpResponse.statusCode)")

            if let headers = httpResponse.allHeaderFields as? [String: Any] {
                print("Headers: \(headers)")
            }

            if let data = response.data,
               let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Response Body:\n\(prettyString)")
            }

            print("======================================\n")

        case .failure(let error):
            print("❌ [Error] =======================")
            print("Status Code: \(httpResponse.statusCode)")
            print("URL: \(httpResponse.url?.absoluteString ?? "URL을 찾을 수 없습니다")")
            print("Error: \(error.localizedDescription)")
            print("======================================\n")
        }
    }
}
