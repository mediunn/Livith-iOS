//
//  DebugNetworkPlugin.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - BodyDisplayMode

/// DebugNetworkPlugin이 Body를 출력하는 방식을 제어합니다.
///
/// ```swift
/// // 전체 출력 (기본값)
/// DebugNetworkPlugin(bodyDisplayMode: .full)
///
/// // 최대 200자까지만 출력하고 나머지는 생략
/// DebugNetworkPlugin(bodyDisplayMode: .truncated(200))
///
/// // Body를 출력하지 않음 (헤더와 상태 코드만 확인할 때 유용)
/// DebugNetworkPlugin(bodyDisplayMode: .omitted)
/// ```
public enum BodyDisplayMode: Sendable {
    /// Body 전문을 출력합니다.
    case full
    /// Body를 지정된 글자 수(maxLength)까지만 출력하고 나머지는 `...(truncated)`로 생략합니다.
    case truncated(maxLength: Int)
    /// Body를 출력하지 않습니다. `(omitted)`로 표시됩니다.
    case omitted
}

// MARK: - DebugNetworkPlugin

/// 네트워크 요청/응답을 구조화된 박스 프레임으로 출력하는 디버그 플러그인입니다.
///
/// REQUEST, RESPONSE, ERROR 블록으로 구분하여 출력하며,
/// 토큰, 이메일 등 민감 정보는 자동으로 `***` 마스킹됩니다.
///
/// ```swift
/// // 기본 사용
/// NetworkClient(plugins: [DebugNetworkPlugin()])
///
/// // Body 길이 제한 + 커스텀 출력
/// NetworkClient(plugins: [
///     DebugNetworkPlugin(
///         bodyDisplayMode: .truncated(300),
///         output: { NSLog("[LivithNetworking] %@", $0) }
///     )
/// ])
/// ```
public struct DebugNetworkPlugin: NetworkPlugin {
    private let bodyDisplayMode: BodyDisplayMode
    private let output: @Sendable (String) -> Void

    /// DebugNetworkPlugin을 생성합니다.
    /// - Parameters:
    ///   - bodyDisplayMode: Body 출력 모드. 기본값은 `.truncated(1000)` (최대 1000자).
    ///   - output: 로그를 출력할 클로저. 기본값은 `print`.
    public init(
        bodyDisplayMode: BodyDisplayMode = .truncated(maxLength: 1000),
        output: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.bodyDisplayMode = bodyDisplayMode
        self.output = output
    }

    public func willSend(
        _ request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {
        var lines: [String] = []
        lines.append(Self.separator)
        lines.append("🌐 REQUEST")
        lines.append("  Method:  \(request.httpMethod ?? "-")")
        lines.append("  URL:     \(sanitizedURLString(from: request.url))")
        lines.append("  Headers: \(formatHeaders(request.allHTTPHeaderFields))")
        lines.append("  Body:    \(formatBody(request.httpBody))")
        lines.append(Self.separator)
        output(lines.joined(separator: "\n"))
    }

    public func didReceive(
        _ result: Result<NetworkPluginResponse, NetworkError>,
        request: URLRequest,
        endpoint: NetworkEndpoint
    ) async {
        switch result {
        case .success(let response):
            var lines: [String] = []
            lines.append(Self.separator)
            lines.append("📥 RESPONSE")
            lines.append("  Status:  \(response.response.statusCode) \(statusDescription(response.response.statusCode))")
            lines.append("  URL:     \(sanitizedURLString(from: request.url))")
            lines.append("  Body:    \(formatBody(response.data))")
            lines.append(Self.separator)
            output(lines.joined(separator: "\n"))
        case .failure(let error):
            var lines: [String] = []
            lines.append(Self.separator)
            lines.append("❌ ERROR")
            lines.append("  Reason:  \(errorSummary(error))")
            lines.append("  URL:     \(sanitizedURLString(from: request.url))")
            lines.append(Self.separator)
            output(lines.joined(separator: "\n"))
        }
    }
}

// MARK: - Helpers

private extension DebugNetworkPlugin {
    static let sensitiveKeys: Set<String> = [
        "accessToken", "refreshToken", "identityToken", "token",
        "email", "providerID", "providerId"
    ]

    static let sensitiveHeaders: Set<String> = [
        "Authorization", "Cookie"
    ]

    static let separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    func sanitizedURLString(from url: URL?) -> String {
        guard let url else {
            return "-"
        }
        return url.path
    }

    func formatHeaders(_ headers: [String: String]?) -> String {
        guard let headers, !headers.isEmpty else {
            return "(none)"
        }
        let entries = headers
            .map { key, value -> String in
                let displayValue: String
                if Self.sensitiveHeaders.contains(key) {
                    if key.caseInsensitiveCompare("Authorization") == .orderedSame,
                       value.hasPrefix("Bearer ")
                    {
                        displayValue = "Bearer ***"
                    } else {
                        displayValue = "***"
                    }
                } else {
                    displayValue = value
                }
                return "\(key): \(displayValue)"
            }
            .sorted()
        return "[\(entries.joined(separator: ", "))]"
    }

    func formatBody(_ data: Data?) -> String {
        guard let data else {
            return "(none)"
        }
        if case .omitted = bodyDisplayMode {
            return "(omitted)"
        }
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return "(\(data.count) bytes)"
        }
        let masked = maskSensitiveValues(in: json)
        guard let maskedData = try? JSONSerialization.data(
            withJSONObject: masked,
            options: [.sortedKeys]
        ),
              let string = String(data: maskedData, encoding: .utf8)
        else {
            return "(\(data.count) bytes)"
        }
        if case .truncated(let maxLength) = bodyDisplayMode, string.count > maxLength {
            let index = string.index(string.startIndex, offsetBy: maxLength)
            return "\(string[..<index])...(truncated)"
        }
        return string
    }

    func maskSensitiveValues(in json: Any) -> Any {
        if let dict = json as? [String: Any] {
            var result: [String: Any] = [:]
            for (key, value) in dict {
                if Self.sensitiveKeys.contains(key) {
                    result[key] = "***"
                } else {
                    result[key] = maskSensitiveValues(in: value)
                }
            }
            return result
        } else if let array = json as? [Any] {
            return array.map { maskSensitiveValues(in: $0) }
        }
        return json
    }

    func errorSummary(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "invalidURL"
        case .invalidRequest:
            return "invalidRequest"
        case .encodingFailed:
            return "encodingFailed"
        case .noConnection:
            return "noConnection"
        case .timeout:
            return "timeout"
        case .cancelled:
            return "cancelled"
        case .invalidResponse:
            return "invalidResponse"
        case .noData:
            return "noData"
        case .decodingFailed:
            return "decodingFailed"
        case .badRequest:
            return "badRequest"
        case .unauthorized:
            return "unauthorized"
        case .forbidden:
            return "forbidden"
        case .notFound:
            return "notFound"
        case .clientError(let statusCode, _):
            return "clientError(\(statusCode))"
        case .serverError(let statusCode, _):
            return "serverError(\(statusCode))"
        case .unknown:
            return "unknown"
        }
    }

    func statusDescription(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 201: return "Created"
        case 204: return "No Content"
        case 301: return "Moved Permanently"
        case 302: return "Found"
        case 304: return "Not Modified"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 405: return "Method Not Allowed"
        case 409: return "Conflict"
        case 422: return "Unprocessable Entity"
        case 429: return "Too Many Requests"
        case 500: return "Internal Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        case 504: return "Gateway Timeout"
        default: return ""
        }
    }
}
