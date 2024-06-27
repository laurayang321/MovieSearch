//
//  APICache.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-26.
//

import Foundation

class APICache {
    static let shared = APICache()
    private var cache = NSCache<NSString, MovieResponse>()
    
    private init() {}
    
    func getResponse(forKey key: String) -> MovieResponse? {
        return cache.object(forKey: key as NSString)
    }
    
    func setResponse(_ response: MovieResponse, forKey key: String) {
        cache.setObject(response, forKey: key as NSString)
    }
}
