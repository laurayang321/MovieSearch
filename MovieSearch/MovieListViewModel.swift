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
    
    func search(name: String) async {
        do {
            let movies = try await WebService().getMovies(searchTerm: name)
            self.movies = movies.map(MovieViewModel.init)
        } catch {
            print(error)
        }
        
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
