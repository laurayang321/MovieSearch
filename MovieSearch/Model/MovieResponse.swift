//
//  MovieResponse.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-26.
//

import Foundation

// Model representing the response from the movie API
class MovieResponse: Decodable {
    
    let movies: [Movie]
    let totalResults: String
    let Response: String
    let Error: String?
    
    private enum CodingKeys: String, CodingKey {
        case movies = "Search"
        case totalResults = "totalResults"
        case Response
        case Error
    }
    
    // Initializer to create a MovieResponse manually
    init(movies: [Movie], totalResults: String, Response: String, Error: String? = nil) {
        self.movies = movies
        self.totalResults = totalResults
        self.Response = Response
        self.Error = Error
    }
}
