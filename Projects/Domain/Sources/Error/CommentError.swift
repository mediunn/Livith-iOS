//
//  CommentError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum CommentError: DomainError {
    case noConnection
    case serverError
    case invalidResponse
    case unknown
    case concertNotFound
    case invalidID
    case invalidSize
    case invalidCursor
    case emptyContent
    case contentTooLong
    case userNotFound
    case withdrawn
    case commentNotFound
    case forbidden
    case reportReasonTooLong
    case cancelled
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .invalidID:
            return "잘못된 요청입니다."
        case .invalidSize, .invalidCursor:
            return "잘못된 요청입니다."
        case .emptyContent:
            return "내용을 입력해주세요."
        case .contentTooLong:
            return "내용은 400자 이내여야 해요."
        case .userNotFound:
            return "사용자를 찾을 수 없어요."
        case .withdrawn:
            return "탈퇴한 회원이에요."
        case .commentNotFound:
            return "댓글을 찾을 수 없어요."
        case .forbidden:
            return "권한이 없어요."
        case .reportReasonTooLong:
            return "신고 사유는 200자 이내여야 해요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
    
    public static func from(message: String) -> CommentError {
        switch message {
        case "해당 콘서트가 존재하지 않습니다.":
            return .concertNotFound
        case "id는 양의 정수여야 합니다.":
            return .invalidID
        case "size must not be less than 1":
            return .invalidSize
        case "유효하지 않은 cursor 형식입니다.":
            return .invalidCursor
        case "content should not be empty":
            return .emptyContent
        case "content must be shorter than or equal to 400 characters":
            return .contentTooLong
        case "해당 유저가 존재하지 않습니다.":
            return .userNotFound
        case "탈퇴한 회원입니다.":
            return .withdrawn
        case "댓글을 찾을 수 없습니다.":
            return .commentNotFound
        case "본인의 댓글만 삭제할 수 있습니다.":
            return .forbidden
        case "content must be shorter than or equal to 200 characters":
            return .reportReasonTooLong
        default:
            return .unknown
        }
    }
}
