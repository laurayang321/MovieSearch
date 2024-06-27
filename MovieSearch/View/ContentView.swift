//
//  ContentView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import SwiftUI

struct ContentView: View {
    
    // Constants
    private let moviesNavigationTitle = "Movies"
    private let noMoreResultsText = "No more results"
    private let searchFieldPrompt = "Search movies"
    
    @StateObject private var movieListVM = MovieListViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack{
                if movieListVM.isRefreshing && movieListVM.movies.isEmpty {
                    ProgressView()
                } else {
                    List {
                        ForEach(movieListVM.movies.indices, id: \.self) { index in
                            let movie = movieListVM.movies[index]
                            
                            MovieRowView(movie: movie)
                            .onAppear {
                                if index == movieListVM.movies.count - 1 {
                                    movieListVM.loadMoreMovies()
                                }
                            }
                        }
                        if movieListVM.isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if !movieListVM.searchText.isEmpty && movieListVM.movies.count >= movieListVM.totalResults && movieListVM.movies.count != 0 && !movieListVM.isTyping {
                            Section(header: EmptyView(), footer: EmptyView()) {
                                Text(noMoreResultsText)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .overlay {
                        if movieListVM.movies.isEmpty && !movieListVM.searchText.isEmpty && !movieListVM.isTyping {
                            ContentUnavailableView.search(text: movieListVM.searchText)
                        }
                    }
                }
            }
            .searchable(text: $movieListVM.searchText, prompt: searchFieldPrompt)
            .focused($isSearchFieldFocused)
            .onChange(of: isSearchFieldFocused) {
                if !isSearchFieldFocused {
                    movieListVM.resetSearch()
                }
            }
            .navigationTitle(moviesNavigationTitle)
//            .alert(isPresented: $movieListVM.hasError) {
//                Alert(
//                    title: Text("Error"),
//                    message: Text(movieListVM.error?.errorDescription ?? "Unknown error"),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
