//
//  WebService.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badID
}

class WebService {
    func getMovies(searchTerm: String) async throws -> [Movie] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.omdbapi.com"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: "ac4b79a0"),
            URLQueryItem(name: "s", value: searchTerm)
        ]
        
        guard let url = components.url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.badID
        }
        
        let movieResponse = try? JSONDecoder().decode(MovieResponse.self, from: data)
        
        return movieResponse?.movies ?? []
    }
}
