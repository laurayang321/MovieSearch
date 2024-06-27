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
    private let likeButtonText = "Like"
    private let defaultPosterImage = "defaultPoster"
    private let searchFieldPrompt = "Search movies"
    private let defaultPosterMaxWidth: CGFloat = 100
    private let likeButtonPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    private let likeButtonBackground = RoundedRectangle(cornerRadius: 6)
        .stroke(.blue, lineWidth: 1)
    
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
                            HStack(alignment: .top) {
                                LazyImage(
                                    url: movie.poster,
                                    placeholder: Image(defaultPosterImage)
                                )
                                .frame(maxWidth: defaultPosterMaxWidth)
                                
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .padding(.bottom)
                                    Text(movie.year)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                HStack {
                                    Button(action: {
                                        print("Cell button tapped")
                                    }) {
                                        Text(likeButtonText)
                                            .padding(likeButtonPadding)
                                            .foregroundColor(.blue)
                                            .background(likeButtonBackground)
                                    }
                                }
                            }
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
