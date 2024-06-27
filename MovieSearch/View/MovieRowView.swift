//
//  MovieRowView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-27.
//

import SwiftUI

struct MovieRowView: View {
    
    // Constants
    private let defaultPosterImage = "defaultPoster"
    private let likeButtonText = "Like"
    private let defaultPosterMaxWidth: CGFloat = 100
    private let likeButtonPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    private let likeButtonBackground = RoundedRectangle(cornerRadius: 6)
        .stroke(.blue, lineWidth: 1)
    private let posterShadow: CGFloat = 4
    
    let movie: MovieViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            LazyImage(
                url: movie.poster,
                placeholder: Image(defaultPosterImage)
            )
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: defaultPosterMaxWidth)
            .shadow(radius: posterShadow)
            
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
                    print("[MovieSearchApp] Cell button tapped")
                }) {
                    Text(likeButtonText)
                        .padding(likeButtonPadding)
                        .foregroundColor(.blue)
                        .background(likeButtonBackground)
                }
            }
        }
    }
}
