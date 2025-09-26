//
//  SearchScreenViewModel.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 20.09.2025.
//


import Foundation

@MainActor
final class SearchScreenViewModel: ObservableObject {
    private let repository = MovieRepository()

    @Published private(set) var movieList: [Movie] = []              // arama sonuçları
    @Published private(set) var allMovies: [Movie] = []              // tüm filmler
    @Published private(set) var groupedMovies: [(key: String, value: [Movie])] = [] // kategori → filmler

    func onLoad() async {
        do {
            allMovies = try await repository.loadMovies()
            buildGroups(limitPerCategory: 10)   // keşif görünümü için
            movieList = allMovies               // arama boşsa “hepsi” gibi davranabilir
        } catch {
            print("onLoad error:", error)
            allMovies = []; groupedMovies = []; movieList = []
        }
    }
    
    func buildGroups(limitPerCategory: Int) {
        let grouped = Dictionary(grouping: allMovies) { (m: Movie) in
            (m.category ?? "Diğer").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        groupedMovies = grouped.map { (category, movies) in
            let sorted = movies.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            return (category, Array(sorted.prefix(limitPerCategory)))
        }
        .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }

    func search(searchText: String) async {
        do { movieList = try await repository.search(searchText: searchText) }
        catch {
            movieList = []
        }
    }
}

