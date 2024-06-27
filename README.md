# MovieSearch

MovieSearch is a simple iOS application that allows users to search for movies using the OMDB API. It displays the movie poster, title, year of release, and provides a button for further actions.

## Features

- Search for movies by title
- Display movie details including poster, title, and year of release
- Load more movies as the user scrolls
- Display no search results page when no results return
- Caching of poster images to improve performance
- Caching of API responses to improve performance
- Display placeholders for movies with missing posters
- Debounce mechanism: trigger search after user stops typing for 500 milliseconds to improve user experience
- Detect user is-typing gesture to not show no search results page during user typing

## Tech Stack

- Swift
- SwiftUI
- Combine
- OMDB API

## Usage
1. Launch the app.
2. Enter a movie title in the search bar.
3. View the search results which include the movie poster, title, and year of release.
4. Scroll down to load more results.
5. If no results are found, a ‘No Results’ message will be displayed.
6. Placeholders will be shown for movies with missing posters.
