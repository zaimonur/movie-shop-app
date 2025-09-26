//
//  FavoriteMovieScreen.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import SwiftUI
import CoreData

struct FavoriteMovieScreen: View {
    
    // MARK: - Değişkenler
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorite.createdAt, ascending: false)],
        animation: .default
    ) private var favorites: FetchedResults<Favorite>

    @State private var grouped: [(key: String, value: [Movie])] = []
    @State private var isLoading = false

    private let repository = MovieRepository()
    @State private var allMoviesCache: [Movie] = []
    private var favoriteIDsSorted: [Int64] {
        favorites.map(\.movieId).sorted()
    }
    
    // MARK: - Computed Views
    @ViewBuilder
    private var favoriteMovieScreenContent: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(grouped, id: \.key) { (category, movies) in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(category).font(.title2.bold())
                        Spacer()
                        Text("\(movies.count)")
                            .foregroundStyle(AppColors.textSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 16)

                    CardCarouselView(movies: movies)
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            favoriteMovieScreenContent
        }
        .overlay {
            if !isLoading && grouped.isEmpty {
                ContentUnavailableView(Constant.favoriteMovieEmptyMessage, systemImage: "heart")
            }
        }
        .navigationTitle(Constant.favoriteMovieTitle)
        .navigationBarTitleDisplayMode(.inline)

        // İlk yükleme + favori ID'leri değiştikçe yeniden kur
        .task(id: favoriteIDsSorted) {
            await rebuild()
        }
        .refreshable {
            await rebuild(forceReload: true)
        }
    }

    // MARK: - Build
    @MainActor
    private func rebuild(forceReload: Bool = false) async {
        isLoading = true
        defer { isLoading = false }

        let ids = Set(favorites.map { Int($0.movieId) })
        guard !ids.isEmpty else {
            grouped = []
            return
        }

        //Veriyi al (cache kullan / istenirse zorla yenile)
        var all = allMoviesCache
        if forceReload || all.isEmpty {
            do {
                all = try await repository.loadMovies()
                allMoviesCache = all                           // cache’i güncelle
            } catch {
                // Ağ hatası: elde cache varsa onu kullan, yoksa mevcut grouped'ı koru
                if allMoviesCache.isEmpty { return }           //boşaltma, mevcut ekranı koru
                all = allMoviesCache
            }
        }

        //Favori ID'lerine göre filtrele
        let favMovies = all.filter { m in
            guard let id = m.id else { return false }
            return ids.contains(id)
        }

        //Kategoriye göre grupla ve sırala
        let dict = Dictionary(grouping: favMovies) { (m: Movie) in
            (m.category ?? "Diğer").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        grouped = dict
            .map { (key, values) in
                let sorted = values.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
                return (key, sorted)
            }
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
    }
}

extension FavoriteMovieScreen {
    enum Constant {
        static let favoriteMovieTitle = "Favoriler"
        static let favoriteMovieEmptyMessage = "Favori film yok"
    }
}

// MARK: - Preview
#Preview {
    FavoriteMovieScreen()
}
