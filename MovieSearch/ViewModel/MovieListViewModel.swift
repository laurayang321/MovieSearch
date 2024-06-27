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
    
    @Published var movies: [MovieViewModel] = []
    @Published var hasError = false
    @Published var error: MovieError?
    @Published var isRefreshing = false
    @Published var searchText: String = ""
    @Published var currentPage = 1
    @Published var totalResults = 0
    @Published var isLoadingMore = false
    @Published var isTyping = false
    
    @Published var bag = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.isTyping = false
                self?.resetSearch()
                self?.search(name: searchText)
            }
            .store(in: &bag)
        
        $searchText
            .dropFirst()
            .sink { [weak self] _ in
                self?.isTyping = true
            }
            .store(in: &bag)
    }
    
    func resetSearch() {
        currentPage = 1
        totalResults = 0
        movies.removeAll()
    }
    
    func getMovies(searchTerm: String, page: Int) -> AnyPublisher<MovieResponse, MovieError> {
        let cacheKey = "\(searchTerm)_\(page)"
                
        if let cachedResponse = APICache.shared.getResponse(forKey: cacheKey) {
            return Just(cachedResponse)
                .setFailureType(to: MovieError.self)
                .eraseToAnyPublisher()
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.omdbapi.com"
        components.queryItems = [
            URLQueryItem(name: "apikey", value: "ac4b79a0"),
            URLQueryItem(name: "s", value: searchTerm),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = components.url else {
            return Fail(error: MovieError.badURL).eraseToAnyPublisher()
        }
        
        isRefreshing = true
        hasError = false
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { res in
                guard let response = res.response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode <= 300 else {
                    throw MovieError.invalidStatusCode
                }
                
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: res.data)
                if movieResponse.Response == "False" {
                    return MovieResponse(movies: [], totalResults: "0", Response: "False", Error: movieResponse.Error)
                }
                
                APICache.shared.setResponse(movieResponse, forKey: cacheKey)
                return movieResponse
            }
            .mapError { error in
                if let movieError = error as? MovieError {
                    return movieError
                }
                return MovieError.custom(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    func search(name: String) {
        guard !name.isEmpty else {
            self.movies = []
            return
        }
        
        getMovies(searchTerm: name, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                defer { self?.isRefreshing = false }
                
                switch completion {
                case .failure(let error):
                    switch error {
                    case .noSearchResults:
                        self?.movies = []
                    default:
                        self?.hasError = true
                        self?.error = error
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] movieResponse in
                self?.totalResults = Int(movieResponse.totalResults) ?? 0
                let newMovies = movieResponse.movies.map(MovieViewModel.init)
                self?.movies.append(contentsOf: newMovies)
            }
            .store(in: &bag)
    }
    
    func loadMoreMovies() {
        guard !searchText.isEmpty, !isLoadingMore, movies.count < totalResults else {
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        getMovies(searchTerm: searchText, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingMore = false
                
                switch completion {
                case .failure(let error):
                    switch error {
                    case .noSearchResults:
                        self?.movies = []
                    default:
                        self?.hasError = true
                        self?.error = error
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] movieResponse in
                self?.totalResults = Int(movieResponse.totalResults) ?? 0
                let newMovies = movieResponse.movies.map(MovieViewModel.init)
                self?.movies.append(contentsOf: newMovies)
            }
            .store(in: &bag)
    }

}

struct MovieViewModel: Identifiable {
    
    let movie: Movie
    
    var id: String {
        movie.imdbID
    }
    
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
