//
//  WebService.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-26.
//

import Foundation

class WebService {
    private static let apiKey = "ac4b79a0"
    private static let scheme = "https"
    private static let host = "www.omdbapi.com"
    
    // Build URL for API call
    static func buildURL(for searchTerm: String, page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "s", value: searchTerm),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        return components.url
    }
}
