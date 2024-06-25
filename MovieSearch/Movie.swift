//
//  Movie.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation

struct MovieResponse: Decodable {
    
    let movies: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "Search"
    }
}

struct Movie: Decodable {
    
    // poster, title, year of release and a button
    var imdbID: String
    var poster: String
    var title: String
    var year: String
    var type: String
    
    private enum CodingKeys: String, CodingKey {
        case imdbID = "imdbID"
        case poster = "Poster"
        case title = "Title"
        case year = "Year"
        case type = "Type"
    }
}


enum MovieError: LocalizedError {
    case custom(error: Error)
    case badURL
    // no search result error response, in as-typing search, alert appears too often to affect user experience, so not use this case (assign empty movies data to handle)
    case failedToDecode
    case invalidStatusCode
    
    var errorDescription: String? {
        switch self {
        case .custom(let error):
            return error.localizedDescription
        case .badURL:
            return "Invalid url"
        case .failedToDecode:
            return "Failed to decode response"
        case .invalidStatusCode:
            return "Request falls within an invalid range"
        }
    }
}
