//
//  PreferenceDTOTests.swift
//  LivithNetworkTests
//
//  Created by 김진웅 on 2/4/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import Testing

@testable import LivithNetwork

struct PreferenceDTODecodingTests {
    
    // MARK: - SearchArtistList Tests
    
    @Test("SearchArtistList 디코딩이 정상적으로 되어야 한다")
    func searchArtistList_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 1,
              "name": "Lisa",
              "genreId": 1,
              "imgUrl": "https://yt3.ggpht.com/n03wNjboLyFI5IZmagYapJASpYH6H7d9deJx4WGTRxwRKPOQaYgOSgudEuPBKl__Xz3LwjR11Q=s800-c-k-c0xffffffff-no-rj-mo"
            },
            {
              "id": 2,
              "name": "YOASOBI",
              "genreId": 1,
              "imgUrl": "https://yt3.ggpht.com/WrZt7XVfe0ZoFRtYCxbOM0gSWp2baxrwxw4o1HQIPJZvamwJXHj6dLjbtJmn369lnl8GdY1k=s800-c-k-c0xffffffff-no-rj-mo"
            }
          ],
          "cursor": 18,
          "totalCount": 747
        }
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.SearchArtistList.self, from: json)
        
        // Then
        #expect(result.data.count == 2)
        #expect(result.cursor == 18)
        #expect(result.totalCount == 747)
        
        let firstArtist = result.data[0]
        #expect(firstArtist.id == 1)
        #expect(firstArtist.name == "Lisa")
        #expect(firstArtist.genreId == 1)
        #expect(firstArtist.imageURLString != nil)
        
        let secondArtist = result.data[1]
        #expect(secondArtist.id == 2)
        #expect(secondArtist.name == "YOASOBI")
    }
    
    @Test("SearchArtistList cursor가 nil일때 디코딩이 되어야 한다")
    func searchArtistList_cursor가_nil일때_디코딩이_되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [],
          "cursor": null,
          "totalCount": 0
        }
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.SearchArtistList.self, from: json)
        
        // Then
        #expect(result.data.isEmpty)
        #expect(result.cursor == nil)
        #expect(result.totalCount == 0)
    }
    
    @Test("SearchArtistList imgUrl이 nil일때 디코딩이 되어야 한다")
    func searchArtistList_imgUrl이_nil일때_디코딩이_되어야_한다() throws {
        // Given
        let json = """
        {
          "data": [
            {
              "id": 1,
              "name": "Test Artist",
              "genreId": 2,
              "imgUrl": null
            }
          ],
          "cursor": 1,
          "totalCount": 1
        }
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.SearchArtistList.self, from: json)
        
        // Then
        #expect(result.data.count == 1)
        #expect(result.data[0].imageURLString == nil)
    }
    
    // MARK: - FetchUserPreferredGenreList Tests
    
    @Test("FetchUserPreferredGenreList 디코딩이 정상적으로 되어야 한다")
    func fetchUserPreferredGenreList_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        [
          {
            "id": 1,
            "userId": 1,
            "name": "JPOP",
            "imgUrl": "https://i.imgur.com/Odi5v7K.jpeg"
          },
          {
            "id": 2,
            "userId": 1,
            "name": "ROCK_METAL",
            "imgUrl": "https://i.imgur.com/uCkAExC.jpeg"
          }
        ]
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserPreferredGenreList.self, from: json)
        
        // Then
        #expect(result.count == 2)
        
        let firstGenre = result[0]
        #expect(firstGenre.id == 1)
        #expect(firstGenre.userID == 1)
        #expect(firstGenre.name == "JPOP")
        #expect(firstGenre.imageURLString == "https://i.imgur.com/Odi5v7K.jpeg")
        
        let secondGenre = result[1]
        #expect(secondGenre.id == 2)
        #expect(secondGenre.userID == 1)
        #expect(secondGenre.name == "ROCK_METAL")
        #expect(secondGenre.imageURLString == "https://i.imgur.com/uCkAExC.jpeg")
    }
    
    @Test("FetchUserPreferredGenreList 빈 배열일때 디코딩이 되어야 한다")
    func fetchUserPreferredGenreList_빈_배열일때_디코딩이_되어야_한다() throws {
        // Given
        let json = "[]".data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserPreferredGenreList.self, from: json)
        
        // Then
        #expect(result.isEmpty)
    }
    
    // MARK: - FetchUserPreferredArtistList Tests
    
    @Test("FetchUserPreferredArtistList 디코딩이 정상적으로 되어야 한다")
    func fetchUserPreferredArtistList_디코딩이_정상적으로_되어야_한다() throws {
        // Given
        let json = """
        [
            {
              "id": 1,
              "userId": 1,
              "genreId": 1,
              "name": "Lisa",
              "imgUrl": "https://yt3.ggpht.com/n03wNjboLyFI5IZmagYapJASpYH6H7d9deJx4WGTRxwRKPOQaYgOSgudEuPBKl__Xz3LwjR11Q=s800-c-k-c0xffffffff-no-rj-mo"
            },
            {
              "id": 4,
              "userId": 1,
              "genreId": 4,
              "name": "Ado",
              "imgUrl": "https://yt3.ggpht.com/BKpE74RwbPJ8zLaad9Y2XoX7SmIEsoma1KB8dNzwtWwiOqgTNnYI_guEP1iAaTBrdk4nHakx=s800-c-k-c0xffffffff-no-rj-mo"
            }
          ]
        """.data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserPreferredArtistList.self, from: json)
        
        // Then
        #expect(result.count == 2)
        
        let firstArtist = result[0]
        #expect(firstArtist.id == 1)
        #expect(firstArtist.userID == 1)
        #expect(firstArtist.genreID == 1)
        #expect(firstArtist.name == "Lisa")
        #expect(firstArtist.imageURLString != nil)
        
        let secondArtist = result[1]
        #expect(secondArtist.id == 4)
        #expect(secondArtist.userID == 1)
        #expect(secondArtist.genreID == 4)
        #expect(secondArtist.name == "Ado")
    }
    
    @Test("FetchUserPreferredArtistList 빈 배열일때 디코딩이 되어야 한다")
    func fetchUserPreferredArtistList_빈_배열일때_디코딩이_되어야_한다() throws {
        // Given
        let json = "[]".data(using: .utf8)!
        
        // When
        let result = try JSONDecoder().decode(DTO.Response.FetchUserPreferredArtistList.self, from: json)
        
        // Then
        #expect(result.isEmpty)
    }
}
