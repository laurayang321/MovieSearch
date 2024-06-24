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
    @State private var labelText: String = ""
    @State private var showType: Bool = false
    
    var body: some View {
        VStack {
            NavigationView {
                List(movieListVM.movies, id:\.imdbId) { movie in
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
                                    showType.toggle()
                                    labelText = showType ? movie.type : ""
                                }, label: {
                                    if !showType {
                                        Text("Show Type ")
                                    } else {
                                        Text("Hide Type ")
                                    }
                                })
                                Text(labelText)
                            }
                        }
                    }
                }.listStyle(.plain)
                    .searchable(text: $searchText)
                    .onChange(of: searchText) {
                        Task {
                            if !searchText.isEmpty && searchText.count > 3 {
                                await movieListVM.search(name: searchText)
                            } else {
                                movieListVM.movies.removeAll()
                            }
                        }
                    }
                    .navigationTitle("Movies")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
