//
//  ImageCache.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-25.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private var cache: [URL: UIImage] = [:]

    func getImage(for url: URL) -> UIImage? {
        return cache[url]
    }

    func setImage(_ image: UIImage, for url: URL) {
        cache[url] = image
    }
}
