//
//  ContentView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var movieListVM = MovieListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack{
                if movieListVM.isRefreshing {
                    ProgressView()
                } else {
                    List(movieListVM.movies, id: \.imdbId) { movie in
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
                    }
                    .listStyle(.plain)
                    .overlay {
                        if movieListVM.movies.isEmpty && !movieListVM.searchText.isEmpty {
                            ContentUnavailableView.search(text: movieListVM.searchText)
                        }
                    }
                }
            }
            .searchable(text: $movieListVM.searchText, prompt: "Search movies")
            .navigationTitle("Movies")
            .alert(isPresented: $movieListVM.hasError) {
                Alert(
                    title: Text("Error"),
                    message: Text(movieListVM.error?.errorDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
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
