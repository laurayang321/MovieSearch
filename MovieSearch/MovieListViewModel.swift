//
//  MovieListViewModel.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import Foundation
import Combine

@MainActor
class MovieListViewModel: ObservableObject {
    
    @Published var movieResponse: [MovieResponse] = []
    @Published var movies: [MovieViewModel] = []
    @Published var hasError = false
    @Published var error: MovieError?
    @Published private(set) var isRefreshing = false
    @Published var searchText: String = ""
    
    @Published var bag = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.search(name: searchText)
            }
            .store(in: &bag)
    }
    
    func search(name: String) {
        guard !name.isEmpty else {
            self.movies = []
            return
        }
        do {
            try getMovies(name)
        } catch {
            self.hasError = true
            self.error = MovieError.custom(error: error)
        }
    }
    
    func getMovies(_ searchTerm: String) throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.omdbapi.com"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: "ac4b79a0"),
            URLQueryItem(name: "s", value: searchTerm)
        ]
        
        guard let url = components.url else {
            throw MovieError.badURL
        }
        
        isRefreshing = true
        hasError = false
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap { res in
                guard let response = res.response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode <= 300 else {
                    throw MovieError.invalidStatusCode
                }
                
                let decoder = JSONDecoder()
                let movieResponse = try? decoder.decode(MovieResponse.self, from: res.data)
                return movieResponse?.movies ?? []
            }
            .sink { [weak self] completion in
                defer { self?.isRefreshing = false }
                
                switch completion {
                case .failure(let error):
                    self?.hasError = true
                    self?.error = MovieError.custom(error: error)
                case .finished:
                    break
                }
                
            } receiveValue: { [weak self] movies in
                self?.movies = movies.map(MovieViewModel.init)
            }
            .store(in: &bag)
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
