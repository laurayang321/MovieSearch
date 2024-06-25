//
//  ContentView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var movieListVM = MovieListViewModel()
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            List(movieListVM.movies, id: \.imdbId) { movie in
                HStack {
                    AsyncImage(url: movie.poster, content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100)
                    }, placeholder: {
                        ProgressView()
                    })
                    VStack(alignment: .leading) {
                        Text(movie.title)
                        Text(movie.year)
                        HStack {
                            Button(action: {
                                movieListVM.toggleLabelVisibility(for: movie)
                            }) {
                                Text("Show type")
                            }
                            if movieListVM.visibleLabels[movie.imdbId] == true {
                                Text(movie.type)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(8)
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) {
                Task {
                    if !searchText.isEmpty && searchText.count > 3 {
                        await movieListVM.search(name: searchText)
                    } else {
                        movieListVM.movies.removeAll()
                    }
                    // Initialize visibility states for new search results
                    for movie in movieListVM.movies {
                        movieListVM.visibleLabels[movie.imdbId] = false
                    }
                }
            }
            .navigationTitle("Movies")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
