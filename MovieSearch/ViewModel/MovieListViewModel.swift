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
    @Published var currentPage = 1 // each page returns max 10 movies
    @Published var totalResults = 0
    @Published var isLoadingMore = false
    @Published var isTyping = false
    
    @Published var bag = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    // Setup bindings to handle search text changes
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
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
    
    // Reset search results and pagination
    func resetSearch() {
        currentPage = 1
        totalResults = 0
        isRefreshing = false
        movies.removeAll()
    }
    
    // Fetch movies from the API, using cache if available
    func getMovies(searchTerm: String, page: Int) -> AnyPublisher<MovieResponse, MovieError> {
        let cacheKey = "\(searchTerm)_\(page)"
                
        // Check cache first
        if let cachedResponse = APICache.shared.getResponse(forKey: cacheKey) {
            print("[MovieSearchApp] Returning cached response for key: \(cacheKey)")
            return Just(cachedResponse)
                .setFailureType(to: MovieError.self)
                .eraseToAnyPublisher()
        }

        guard let url = WebService.buildURL(for: searchTerm, page: page) else {
            print("[MovieSearchApp] Invalid URL for searchTerm: \(searchTerm) and page: \(page)")
            return Fail(error: MovieError.badURL).eraseToAnyPublisher()
        }
        
        isRefreshing = true
        hasError = false
        
        // Fetch data from API
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { res in
                guard let response = res.response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode <= 300 else {
                    print("[MovieSearchApp] Invalid status code: \(res.response)")
                    throw MovieError.invalidStatusCode
                }
                
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: res.data)
                if movieResponse.Response == "False" {
                    print("[MovieSearchApp] No search results found for searchTerm: \(searchTerm)")
                    return MovieResponse(movies: [], totalResults: "0", Response: "False", Error: movieResponse.Error)
                }
                
                // Cache the response
                print("[MovieSearchApp] Successfully fetched movie response: \(movieResponse)")
                APICache.shared.setResponse(movieResponse, forKey: cacheKey)
                return movieResponse
            }
            .mapError { error in
                print("[MovieSearchApp] Error fetching movie response: \(error)")
                if let movieError = error as? MovieError {
                    return movieError
                }
                return MovieError.custom(error: error)
            }
            .eraseToAnyPublisher()
    }
    
    // Search for movies
    func search(name: String) {
        print("[MovieSearchApp] Search called with name: \(name)") // Debugging statement
        guard !name.isEmpty else {
            self.movies = []
            return
        }
        
        getMovies(searchTerm: name, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                print("[MovieSearchApp] Completion: \(completion)")
                defer { self?.isRefreshing = false }
                
                switch completion {
                case .failure(let error):
                    print("[MovieSearchApp] Search failed with error: \(error)")
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
                print("[MovieSearchApp] Received movie response: \(movieResponse)")
                self?.totalResults = Int(movieResponse.totalResults) ?? 0
                let newMovies = movieResponse.movies.map(MovieViewModel.init)
                self?.movies.append(contentsOf: newMovies)
                print("[MovieSearchApp] Fetched movies: \(newMovies.count)")
                print("[MovieSearchApp] Movies property updated, total count: \(self?.movies.count ?? 0)")
            }
            .store(in: &bag)
    }
    
    // Load more movies for pagination
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
                print("[MovieSearchApp] Loaded more movies: \(newMovies.count)")
                print("[MovieSearchApp] Movies property updated, total count: \(self?.movies.count ?? 0)")
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
