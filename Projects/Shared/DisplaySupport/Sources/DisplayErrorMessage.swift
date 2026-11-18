import Foundation

import Domain

public enum DisplayErrorMessage {
    public static func message(for error: any Error) -> String {
        switch error {
        case let error as AuthError:
            return message(for: error)
        case let error as CalendarError:
            return message(for: error)
        case let error as CommentError:
            return message(for: error)
        case let error as ConcertError:
            return message(for: error)
        case let error as ConcertMatchingError:
            return message(for: error)
        case let error as NotificationError:
            return message(for: error)
        case let error as PreferenceError:
            return message(for: error)
        case let error as SearchError:
            return message(for: error)
        case let error as SetlistError:
            return message(for: error)
        case let error as SongError:
            return message(for: error)
        case let error as UserError:
            return message(for: error)
        default:
            return error.localizedDescription
        }
    }

    private static func message(for error: AuthError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .withdrawn:
            return "탈퇴한 회원입니다."
        case .recentlyWithdrawn:
            return "탈퇴 후 7일이 지나지 않았어요."
        case .duplicateNickname:
            return "이미 존재하는 닉네임이에요."
        case .nicknameTooLong:
            return "닉네임은 10자 이내여야 해요."
        case .emptyNickname:
            return "닉네임을 입력해주세요."
        case .invalidNickname:
            return "닉네임 형식이 올바르지 않아요."
        case .nicknameNotConfirmed:
            return "닉네임 중복 확인을 해주세요."
        case .requiredTermsNotAgreed:
            return "필수 약관에 동의해주세요."
        case .userNotFound:
            return "해당 유저를 찾을 수 없어요."
        case .emptyReason:
            return "탈퇴 사유를 선택해주세요."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .emptyGenreList:
            return "최소 1개의 장르는 선택해야 합니다."
        case .genreNotFound:
            return "해당 장르를 찾을 수 없습니다."
        case .genreExceedsLimit:
            return "최대 3개의 장르만 선택할 수 있습니다."
        case .artistNotFound:
            return "해당 아티스트를 찾을 수 없습니다."
        case .artistExceedsLimit:
            return "최대 3개의 아티스트만 선택할 수 있습니다."
        }
    }

    private static func message(for error: CalendarError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "인증이 필요해요."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }

    private static func message(for error: CommentError) -> String {
        switch error {
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

    private static func message(for error: ConcertError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .invalidID, .invalidSize:
            return "잘못된 요청입니다."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .artistNotFound:
            return "아티스트를 찾을 수 없어요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: ConcertMatchingError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .matchFailed:
            return "공연 정보를 불러오지 못했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: NotificationError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .notificationNotFound:
            return "알림을 찾을 수 없어요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: PreferenceError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .userNotFound:
            return "해당 유저가 존재하지 않습니다."
        case .withdrawn:
            return "탈퇴한 회원입니다."
        case .invalidCursor:
            return "잘못된 커서 값입니다."
        case .invalidSize:
            return "잘못된 사이즈 값입니다."
        case .genreNotFound:
            return "해당 장르를 찾을 수 없습니다."
        case .minGenreRequired:
            return "최소 1개의 장르는 선택해야 합니다."
        case .maxGenreExceeded:
            return "최대 3개의 장르만 선택할 수 있습니다."
        case .invalidGenreID:
            return "장르 ID는 숫자여야 합니다."
        case .artistNotFound:
            return "해당 아티스트를 찾을 수 없습니다."
        case .maxArtistExceeded:
            return "최대 3개의 아티스트만 선택할 수 있습니다."
        case .invalidArtistID:
            return "아티스트 ID는 숫자여야 합니다."
        }
    }

    private static func message(for error: SearchError) -> String {
        switch error {
        case .noSearchResult:
            return "검색 결과가 없습니다."
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했습니다."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .invalidGenre:
            return "유효하지 않은 장르입니다."
        case .invalidStatus:
            return "유효하지 않은 상태값입니다."
        case .invalidSort:
            return "유효하지 않은 정렬값입니다."
        case .invalidSize:
            return "사이즈는 양의 정수여야 합니다."
        case .invalidCursor:
            return "유효하지 않은 커서 형식입니다."
        case .invalidID:
            return "ID는 1 이상의 정수여야 합니다."
        case .missingKeyword:
            return "검색어는 필수입니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: SetlistError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .notFound:
            return "셋리스트를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .invalidID:
            return "잘못된 요청입니다."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .combinationNotFound:
            return "해당 셋리스트에 포함된 콘서트가 아니에요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: SongError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .notFound:
            return "노래 정보를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .invalidID:
            return "잘못된 요청입니다."
        case .setlistNotFound:
            return "셋리스트를 찾을 수 없어요."
        case .combinationNotFound:
            return "해당 셋리스트에 포함된 노래가 아니에요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }

    private static func message(for error: UserError) -> String {
        switch error {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .serverError:
            return "서버 오류가 발생했어요."
        case .invalidResponse:
            return "데이터를 불러오는데 실패했어요."
        case .invalidRequest:
            return "요청 정보를 확인할 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        case .userNotFound:
            return "해당 유저를 찾을 수 없어요."
        case .duplicateNickname:
            return "이미 사용 중인 닉네임이에요."
        case .nicknameTooLong:
            return "닉네임은 10자 이내여야 해요."
        case .withdrawn:
            return "탈퇴한 회원이에요."
        case .emptyNickname:
            return "닉네임을 입력해주세요."
        case .concertNotFound:
            return "콘서트를 찾을 수 없어요."
        case .invalidConcertID:
            return "잘못된 콘서트 정보에요."
        case .cancelled:
            return "요청이 취소되었습니다."
        }
    }
}
