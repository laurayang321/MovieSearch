//
//  MovieSearchTests.swift
//  MovieSearchTests
//
//  Created by Jing Yang on 2024-06-24.
//

import XCTest
import Combine
@testable import MovieSearch

class MovieListViewModelTests: XCTestCase {

    var viewModel: MovieListViewModel!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        APICache.shared.clear() // Clear cache before each test
        viewModel = MovieListViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func testSearchMoviesNoResults() async {
        // Given
        let expectation = XCTestExpectation(description: "No movies found")
        
        // When
        await MainActor.run {
            viewModel.searchText = "InvalidMovieTitle"
        }
        
        // Then
        await waitForNoMoviesToBeFetched(expectation: expectation)
        XCTAssertTrue(viewModel.movies.isEmpty, "Movies should be empty for an invalid search term")
    }
    
    @MainActor
    func testLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state is correct")
        
        // When
        await MainActor.run {
            viewModel.searchText = "Batman"
        }
        
        // Wait for the state to change to refreshing
        await waitForRefreshingStateToBe(true)
        
        // Then
        XCTAssertTrue(viewModel.isRefreshing, "ViewModel should be in refreshing state")
        
        // Wait for the state to change to not refreshing
        viewModel.$isRefreshing
            .dropFirst()
            .sink { isRefreshing in
                print("[MovieSearchApp] isRefreshing changed to: \(isRefreshing)")
                if !isRefreshing {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertFalse(viewModel.isRefreshing, "[MovieSearchApp] ViewModel should not be in refreshing state after data is fetched")
    }
    
    @MainActor
    private func waitForNoMoviesToBeFetched(expectation: XCTestExpectation) async {
        viewModel.$movies
            .dropFirst()
            .sink { movies in
                print("[MovieSearchApp] Movies fetched: \(movies.count)")
                if movies.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await withCheckedContinuation { continuation in
            wait(for: [expectation], timeout: 10.0) // Increased timeout
            continuation.resume()
        }
    }
        
    @MainActor
    private func waitForRefreshingStateToBe(_ state: Bool) async {
        await withCheckedContinuation { continuation in
            viewModel.$isRefreshing
                .filter { $0 == state }
                .sink { isRefreshing in
                    print("[MovieSearchApp] isRefreshing changed to: \(isRefreshing)")
                    continuation.resume()
                }
                .store(in: &cancellables)
        }
    }
}
