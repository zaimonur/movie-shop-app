//
//  SearchScreen.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//


import SwiftUI
import Kingfisher

struct SearchScreen: View {
    
    // MARK: - Değişkenler
    @StateObject private var viewModel = SearchScreenViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    
    // MARK: - Computed Views
    private var categoriesCarousel: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(viewModel.groupedMovies, id: \.key) { (category, movies) in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(category).font(.title2.bold())
                        Spacer()
                        if !movies.isEmpty {
                            Text("\(movies.count)")
                                .foregroundStyle(AppColors.cardBG)
                                .monospacedDigit()
                        }
                    }
                    .padding(.horizontal, 16)

                    CardCarouselView(movies: movies)
                }
            }
        }
        .padding(.vertical, 12)
    }
    private var searchbar: some View {
        List(viewModel.movieList, id: \.id) { movie in
            NavigationLink {
                MovieDetailScreen(movie: movie)
            } label: {
                HStack(spacing: 12) {
                    if let image = movie.image{
                        KFImage(URL(string: "http://kasimadalan.pe.hu/movies/images/\(image)"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 96)
                            .clipped()
                            .cornerRadius(6)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.name ?? "—").font(.headline)
                        HStack(spacing: 8) {
                            if let year = movie.year {
                                Text("\(year.formatted(.number.grouping(.never)))")
                            }
                            if let rating = movie.rating {
                                Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                    .labelStyle(.titleAndIcon)
                                    .foregroundStyle(AppColors.primary)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColors.dividerBG)
                    }
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.movieList.isEmpty {
                ContentUnavailableView(Constant.contentUnavailable, systemImage: "magnifyingglass")
            }
        }
    }
    private var searchScreenContent: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // KEŞİF: Kategoriler ve CardCarousel
                ScrollView {
                    categoriesCarousel
                }
                .overlay {
                    if viewModel.groupedMovies.isEmpty {
                        ContentUnavailableView(Constant.contentUnavailable, systemImage: "film.stack")
                    }
                }
            }
            else {
                // ARAMA: Dikey sonuç listesi
                searchbar
            }
        }
        .navigationTitle(Constant.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Constant.searchbarPromt
        )
        .onSubmit(of: .search) { triggerSearch(immediate: true) }
        .onChange(of: searchText) {
            _ in triggerSearch()
        }
        .task {
            await viewModel.onLoad()
        }
        .refreshable {
            await viewModel.onLoad()
            if !searchText.isEmpty { await viewModel.search(searchText: searchText) }
        }
    }
    
    // MARK: - Functions
    private func triggerSearch(immediate: Bool = false) {
        searchTask?.cancel()
        searchTask = Task {
            await viewModel.search(searchText: searchText)
        }
    }

    // MARK: - Body
    var body: some View {
        searchScreenContent
    }
}

// MARK: - Constant
extension SearchScreen {
    enum Constant {
        static let searchbarPromt = "Film arayın..."
        static let navigationTitle = "Filmleri Keşfet"
        static let contentUnavailable = "Veri Yok"
    }
}


#Preview {
    NavigationStack { SearchScreen() }
}
