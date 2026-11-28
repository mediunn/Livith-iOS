import Foundation
import Testing

import DisplaySupport
import Domain

@Suite("도메인 에러 표시")
struct DisplayErrorMessageTests {
    @Test("같은 네트워크 실패도 도메인에 따른 기존 문구를 표시한다")
    func preservesExistingMessages() {
        #expect(DisplayErrorMessage.message(for: ConcertError.serverError) == "서버 오류가 발생했어요.")
        #expect(DisplayErrorMessage.message(for: PreferenceError.serverError) == "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.")
    }

    @Test("도메인 외부 에러는 기존 설명을 표시한다")
    func preservesUnknownErrorDescription() {
        let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "시스템 오류"])

        #expect(DisplayErrorMessage.message(for: error) == "시스템 오류")
    }
}
