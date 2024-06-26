//
//  ContentView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import SwiftUI

struct ContentView: View {
    
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
                                    placeholder: Image("defaultPoster")
                                )
                                .frame(maxWidth: 100)
                                
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
                                        Text("Buy")
                                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                            .foregroundColor(.blue)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
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
                        } else if !movieListVM.searchText.isEmpty && movieListVM.movies.count >= movieListVM.totalResults && !movieListVM.isTyping {
                            Text("No more results")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
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
            .searchable(text: $movieListVM.searchText, prompt: "Search movies")
            .focused($isSearchFieldFocused)
            .onChange(of: isSearchFieldFocused) {
                if !isSearchFieldFocused {
                    movieListVM.resetSearch()
                }
            }
            .navigationTitle("Movies")
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

struct ContentUnavailableView: View {
    let searchText: String
    
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Text("No movies found for the title \"\(searchText)\".")
                .font(.title2)
                .padding(.bottom, 10)
            
            Text("Please try another title.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
    
    static func search(text: String) -> some View {
        ContentUnavailableView(searchText: text)
    }
}

#Preview {
    ContentView()
}
