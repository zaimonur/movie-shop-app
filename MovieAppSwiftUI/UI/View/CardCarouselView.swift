//
//  CardCarouselView.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 19.09.2025.
//

import SwiftUI
import Kingfisher

// MARK: - Poster Kartı
struct MoviePosterCard: View {
    let title: String
    let rating: Double?
    let url: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage.url(url)
                .placeholder {
                    Rectangle()
                        .fill(.gray.opacity(0.15))
                        .overlay(ProgressView())
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .onFailureImage(UIImage(systemName: "photo"))
                .resizable()
                .scaledToFill()
                .frame(width: 165, height: 235)
                .clipped()
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(AppColors.textSecondary)
                if let rating {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                }
            }
            .foregroundStyle(AppColors.cardBG)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.black.opacity(1), in: Capsule())
            .padding(8)
        }
        .frame(width: 165, height: 235)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Card Carousel
struct CardCarouselView: View {
    let movies: [Movie]
    var onMovieTap: ((Movie) -> Void)? = nil
    private let baseURL = URL(string: "http://kasimadalan.pe.hu/movies/images/")!

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(movies, id: \.id) { movie in
                                            NavigationLink {
                                                MovieDetailScreen(movie: movie)
                                            } label: { 
                                                MoviePosterCard(
                                                    title: movie.name ?? "—",
                                                    rating: movie.rating,
                                                    url: posterURL(for: movie.image)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                    .frame(height: 235)
            }
            .contentMargins(.horizontal, 0)
            .scrollClipDisabled(true)
        }
        .padding(.bottom, 15)
        .foregroundStyle(AppColors.textPrimary)
    }

    private func posterURL(for path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        if path.hasPrefix("/") {
            return baseURL.appendingPathComponent(String(path.dropFirst()))
        } else {
            return baseURL.appendingPathComponent(path)
        }
    }
}
