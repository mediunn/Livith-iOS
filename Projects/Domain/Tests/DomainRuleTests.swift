import Testing

import Domain

@Suite("도메인 입력과 상태 전환")
struct DomainRuleTests {
    @Test("캘린더에서 마지막 일정 유형을 해제해도 선택을 유지한다")
    func keepsLastCalendarScheduleType() {
        var selection = CalendarScheduleSelection()
        _ = selection.toggle(.ticketing)

        let result = selection.toggle(.concert)

        guard case .lastSelectionRequired = result else {
            Issue.record("마지막 선택 해제가 차단되어야 한다")
            return
        }
        #expect(selection.scheduleTypes == [.concert])
    }

    @Test("선호 항목을 세 개 선택하면 새 항목을 추가할 수 없다")
    func limitsPreferenceSelection() {
        let genres = (1...4).map { PreferredGenre(id: $0, name: "장르 \($0)", imageURL: nil) }
        var selection = PreferenceSelection(Array(genres.prefix(3)))

        let result = selection.toggle(id: 4, availableItem: genres[3])

        guard case .limitReached = result else {
            Issue.record("네 번째 선택이 차단되어야 한다")
            return
        }
        #expect(selection.items.map(\.id) == [1, 2, 3])
    }

    @Test("관심 공연 저장 중 추가한 공연은 저장되지 않은 변경으로 남는다")
    func keepsEditsMadeDuringSave() {
        var selection = InterestConcertSelection(concertIDs: [3, 1])
        selection.toggle(concertID: 4)
        let submitted = selection.concertIDs
        selection.toggle(concertID: 2)

        selection.markSaved(concertIDs: submitted)

        #expect(selection.concertIDs == [3, 1, 4, 2])
        #expect(selection.hasUnsavedChanges)
    }

    @Test("공연 요청은 입력을 정리하고 빈 선택 값을 생략한다")
    func normalizesConcertRequest() throws {
        let request = try ConcertRequest(
            title: " 라이빗 공연 ",
            url: " ",
            shouldAutoRegister: true,
            requestContent: " 서울 "
        )

        #expect(request.title == "라이빗 공연")
        #expect(request.url == nil)
        #expect(request.shouldAutoRegister)
        #expect(request.requestContent == "서울")
    }

    @Test("공연 요청은 공백만 있는 제목을 거절한다")
    func rejectsBlankConcertRequestTitle() {
        #expect(throws: ConcertError.invalidRequest) {
            try ConcertRequest(title: " ", url: nil, shouldAutoRegister: false, requestContent: nil)
        }
    }

    @Test("댓글 본문은 빈 값과 최대 글자 수를 넘는 값을 거절한다")
    func rejectsInvalidCommentLength() {
        #expect(throws: CommentError.emptyContent) {
            try ConcertCommentContent("")
        }
        #expect(throws: CommentError.contentTooLong) {
            try ConcertCommentContent(String(repeating: "가", count: 401))
        }
    }
}
