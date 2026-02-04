//
//  PreferenceMapperTests.swift
//  PreferenceDataTests
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing
import Foundation

@testable import PreferenceData
@testable import LivithNetwork
@testable import Domain

@Suite("PreferenceMapper Tests")
struct PreferenceMapperTests {
    let mapper = PreferenceMapper()
    
    @Test("FetchGenreList를 PreferredGenre 배열로 변환")
    func fetchGenreListToDomain() {
        // Given
        let json = """
        [
            {"id": 1, "name": "JPOP", "imgUrl": "https://example.com/jpop.png"},
            {"id": 2, "name": "ROCK_METAL", "imgUrl": "https://example.com/rock.png"}
        ]
        """.data(using: .utf8)!
        
        let dto = try! JSONDecoder().decode(DTO.Response.FetchGenreList.self, from: json)
        
        // When
        let result = mapper.toDomain(from: dto)
        
        // Then
        #expect(result.count == 2)
        #expect(result[0].id == 1)
        #expect(result[0].name == "JPOP")
        #expect(result[0].displayName == "J-POP")
        #expect(result[1].name == "ROCK_METAL")
        #expect(result[1].displayName == "락/메탈")
    }
    
    @Test("FetchArtistList를 ArtistSearchResult로 변환")
    func fetchArtistListToDomain() {
        // Given
        let json = """
        {
            "data": [
                {"id": 1, "name": "YOASOBI", "genreId": 1, "imgUrl": "https://example.com/yoasobi.png"},
                {"id": 2, "name": "ONE OK ROCK", "genreId": 2, "imgUrl": null}
            ],
            "cursor": 3,
            "totalCount": 100
        }
        """.data(using: .utf8)!
        
        let dto = try! JSONDecoder().decode(DTO.Response.SearchArtistList.self, from: json)
        
        // When
        let result = mapper.toDomain(from: dto)
        
        // Then
        #expect(result.artists.count == 2)
        #expect(result.cursor == 3)
        #expect(result.totalCount == 100)
        #expect(result.artists[0].name == "YOASOBI")
        #expect(result.artists[0].genreID == 1)
        #expect(result.artists[1].imageURL == nil)
    }
    
    @Test("FetchUserPreferredGenreList를 PreferredGenre 배열로 변환")
    func fetchUserPreferredGenreListToDomain() {
        // Given
        let json = """
        [
            {"id": 1, "userId": 123, "name": "JPOP", "imgUrl": "https://example.com/jpop.png"}
        ]
        """.data(using: .utf8)!
        
        let dto = try! JSONDecoder().decode(DTO.Response.FetchUserPreferredGenreList.self, from: json)
        
        // When
        let result = mapper.toDomain(from: dto)
        
        // Then
        #expect(result.count == 1)
        #expect(result[0].id == 1)
        #expect(result[0].name == "JPOP")
    }
}
