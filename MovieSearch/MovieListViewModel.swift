//
//  MovieListViewModel.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation

@MainActor
class MovieListViewModel: ObservableObject {
    
    @Published var movies: [MovieViewModel] = []
    @Published var visibleLabels: [String: Bool] = [:]
    
    func search(name: String) async {
        do {
            let movies = try await WebService().getMovies(searchTerm: name)
            self.movies = movies.map(MovieViewModel.init)
        } catch {
            print(error)
        }
    }
    
    func toggleLabelVisibility(for movie: MovieViewModel) {
        // Reset all labels
        for key in visibleLabels.keys {
            visibleLabels[key] = false
        }
        // Toggle the specific movie's label
        visibleLabels[movie.imdbId]?.toggle()
    }
}

struct MovieViewModel {
    let movie: Movie
    
    var imdbId: String {
        movie.imdbID
    }
    
    var title: String {
        movie.title
    }
    
    var year: String {
        movie.year
    }
    
    var type: String {
        movie.type
    }
    
    var poster: URL? {
        URL(string: movie.poster)
    }
}
