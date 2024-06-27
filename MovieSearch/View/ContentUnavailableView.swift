//
//  ContentUnavailableView.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-26.
//

import SwiftUI

struct ContentUnavailableView: View {
    // Constants
    private let noMoviesFoundText = "No movies found for the title \"%@\"."
    private let tryAnotherTitleText = "Please try another title."
    private let iconWidth: CGFloat = 80
    private let iconBtmPadding: CGFloat = 20
    private let textBtmPadding: CGFloat = 10
    
    let searchText: String
    
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconWidth, height: iconWidth)
                .foregroundColor(.gray)
                .padding(.bottom, iconBtmPadding)
            
            Text(String(format: noMoviesFoundText, searchText))
                .font(.title2)
                .padding(.bottom, textBtmPadding)
            
            Text(tryAnotherTitleText)
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
    ContentUnavailableView(searchText: "Batman")
}
