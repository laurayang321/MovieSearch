//
//  Movie.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation

// Model representing a single movie
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
