//
//  HomePageScreen.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 19.09.2025.
//

import SwiftUI
import Kingfisher

struct HomePageScreen: View {
    
    // MARK: - Değişkenler
    @StateObject private var viewModel = HomePageViewModel()
    
    // MARK: - init
    init() {
        NavigationBarStyle.setup()
    }
    
    // MARK: - Computed Views
    @ViewBuilder
    private var topFive: some View {
        if !viewModel.topRated.isEmpty {
            Text(Constant.topFiveMoviesText)
                .font(.title2.bold())
                .padding(.horizontal, 16)
                .foregroundStyle(AppColors.textPrimary)
            
            CardCarouselView(
                movies: viewModel.topRated,
            )
            .padding(.top, -4)
        }
    }
    @ViewBuilder
    private var newestFive: some View {
        Text(Constant.newestMoviesText)
            .font(.title2.bold())
            .padding(.horizontal, 16)
            .foregroundStyle(AppColors.textPrimary)
        
        ForEach(viewModel.newest, id: \.id) { movie in
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(movie.name ?? "—")
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        if let year = movie.year {
                            Text("Yıl: \(year.formatted(.number.grouping(.never)))")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        if let rating = movie.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                topFive
                newestFive
            }
            .padding(.top)
        }
        .navigationTitle(Constant.navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppColors.textPrimary)
        .task {
            await viewModel.onLoad()
        }
        .background(Color(AppColors.appBG))
    }
}

// MARK: - Constant
extension HomePageScreen {
    enum Constant {
        static let navigationTitleText = "Movie App"
        static let topFiveMoviesText = "TOP 5 FİLM"
        static let newestMoviesText = "EN YENİ 5 FİLM"
    }
}

// MARK: - Preview
#Preview {
    HomePageScreen()
}
