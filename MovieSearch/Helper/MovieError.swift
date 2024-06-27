//
//  MovieError.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-26.
//

import Foundation

enum MovieError: LocalizedError, Equatable {
    case custom(error: Error)
    case badURL
    // no search result error response, in as-typing search, alert appears too often to affect user experience, so not use this case (assign empty movies data to handle)
    case failedToDecode
    case noSearchResults
    case invalidStatusCode
    
    var errorDescription: String? {
        switch self {
        case .custom(let error):
            return error.localizedDescription
        case .badURL:
            return "Invalid url"
        case .noSearchResults:
            return "No valid search results"
        case .failedToDecode:
            return "Failed to decode response"
        case .invalidStatusCode:
            return "Request falls within an invalid range"
        }
    }
    
    static func ==(lhs: MovieError, rhs: MovieError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}
