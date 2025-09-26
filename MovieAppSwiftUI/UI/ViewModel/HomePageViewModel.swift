//
//  HomePageViewModel.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import Foundation

@MainActor
final class HomePageViewModel: ObservableObject {
    private let repository = MovieRepository()
    @Published private(set) var movieList: [Movie] = []

    var topRated: [Movie] {
        Array(
            movieList
                .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
                .prefix(5)
        )
    }
    var newest: [Movie] {
        Array(
            movieList
                .sorted { ($0.year ?? 0) > ($1.year ?? 0) }
                .prefix(5)
        )
    }

    func onLoad() async {
        do {
            movieList = try await repository.loadMovies()
        }
        catch {
            print(error)
        }
    }
}


