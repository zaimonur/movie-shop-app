//
//  MovieDetailScreen.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 18.09.2025.
//


import SwiftUI
import Kingfisher

struct MovieDetailScreen: View {
    // MARK: - Değişkenler
    let movie: Movie
    private let baseURL = URL(string: "http://kasimadalan.pe.hu/movies/images/")!

    @Environment(\.managedObjectContext) private var moc
    @FetchRequest private var favoriteMatch: FetchedResults<Favorite>
    private var isFavorite: Bool { favoriteMatch.first != nil }

    @StateObject private var cartVM = CartScreenViewModel()
    @State private var isInCart = false
    @State private var isWorking = false
    @State private var showAlert = false
    @State private var alertText = ""

    // MARK: - init
    init(movie: Movie) {
        self.movie = movie
        let mid = Int64(movie.id ?? -1)
        _favoriteMatch = FetchRequest(
            sortDescriptors: [],
            predicate: NSPredicate(format: "movieId == %d", mid),
            animation: .default
        )
    }

    // MARK: - Computed Views
    private var posterURL: URL? {
        guard let path = movie.image, !path.isEmpty else { return nil }
        if path.hasPrefix("/") { return baseURL.appendingPathComponent(String(path.dropFirst())) }
        return baseURL.appendingPathComponent(path)
    }
    
    private var giftButton: some View {
        Button(Constant.giftButtonText, systemImage:"gift") {
            //Button
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppColors.primary)
        .foregroundStyle(AppColors.primaryButtonTextColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    private var favoriteButton: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 28))
                .foregroundColor(isFavorite ? .red : AppColors.primary)
                .scaleEffect(isFavorite ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isFavorite)
        }
    }
    private var addCartButton: some View {
        Button {
            Task { await toggleCart() }
        } label: {
            Label(isInCart ? Constant.addCartButtonRed : Constant.addCartButtonGreen,
                  systemImage: isInCart ? "xmark" : "cart.fill")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .background(isInCart ? AppColors.danger : AppColors.success)
        .foregroundStyle(AppColors.primaryButtonTextColor)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: isInCart)
        .padding(.vertical, 10)
        .disabled(isWorking)
        .overlay {
            if isWorking { ProgressView().tint(.white) }
        }
    }
    private var buttonContent: some View {
        HStack(spacing: 16) {
            giftButton
            favoriteButton
            addCartButton
        }
        .padding(.horizontal)
    }
    private var movieDetailScreenContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            KFImage.url(posterURL)
                .placeholder { Rectangle().fill(.gray.opacity(0.15)).overlay(ProgressView()) }
                .retry(maxCount: 2, interval: .seconds(1))
                .onFailureImage(UIImage(systemName: "photo"))
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                .frame(width:375, height: 425)

            Text(movie.name ?? "—")
                .font(.title.bold())

            HStack(spacing: 12) {
                if let rating = movie.rating {
                    Label {
                            Text(String(format: "%.1f", rating))
                                .foregroundStyle(AppColors.textPrimary) // sadece yazı
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(AppColors.primary) // sadece ikon
                        }
                }
                if let year = movie.year {
                    Label {
                            Text("\(year.formatted(.number.grouping(.never)))")
                                .foregroundStyle(AppColors.textPrimary)
                        } icon: {
                            Image(systemName: "calendar")
                                .foregroundStyle(AppColors.primary)
                        }
                }
                if let cat = movie.category, !cat.isEmpty {
                    Label {
                            Text(cat)
                                .foregroundStyle(AppColors.textPrimary)
                        } icon: {
                            Image(systemName: "tag")
                                .foregroundStyle(AppColors.primary)
                        }
                }
            }
            .foregroundStyle(AppColors.textPrimary)

            if let desc = movie.description, !desc.isEmpty {
                Text(desc)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            buttonContent
        }
        .padding()
    }
    
    // MARK: - Functions
    private func toggleFavorite() {
        guard let id = movie.id else { return }
        if let f = favoriteMatch.first {
            moc.delete(f)
        } else {
            let f = Favorite(context: moc)
            f.movieId = Int64(id)
            f.createdAt = Date()
        }
        try? moc.save()
    }
    
    private func precheckInCart() async {
        await cartVM.getCartMovie(userName: Constant.username)
        isInCart = cartVM.items.contains { ($0.name ?? "") == (movie.name ?? "") }
    }
    
    private func addToCart() async {
        isWorking = true
        defer { isWorking = false }

        // Backend 0’ları “boş” saymasın diye güvenli min değerler
        let name = (movie.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let image = movie.image ?? ""
        let price = max(movie.price ?? 1, 1)
        let category = movie.category ?? ""
        let rating = max(movie.rating ?? 1, 0.1)
        let year = max(movie.year ?? 1900, 1)
        let director = movie.director ?? ""
        let description = (movie.description ?? "").isEmpty ? "-" : (movie.description ?? "")

        await cartVM.cartAddMovie(
            name: name, image: image, price: price,
            category: category, rating: rating, year: year,
            director: director, description: description,
            orderAmount: 1, userName: Constant.username
        )

        // UI’ı yansıt
        isInCart = true
        // İstersen güncel listeyi çek
        await cartVM.getCartMovie(userName: Constant.username)
    }
    
    private func removeFromCart() async {
        isWorking = true
        defer { isWorking = false }

        // Önce sepetteki item’ı bul (ad üzerinden)
        await cartVM.getCartMovie(userName: Constant.username)
        if let item = cartVM.items.first(where: { ($0.name ?? "") == (movie.name ?? "") }),
           let id = item.cartId {
            await cartVM.deleteCartMovie(id: id, userName: Constant.username)
            isInCart = false
        } else {
            // cartId yoksa kullanıcıya bilgi ver
            alertText = Constant.alertText
            showAlert = true
        }
    }

    private func toggleCart() async {
        if isInCart {
            await removeFromCart()
        }
        else {
            await addToCart()
        }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            movieDetailScreenContent
        }
        .navigationTitle(movie.name ?? "Detay")
        .navigationBarTitleDisplayMode(.inline)
        .task { await precheckInCart() } // ekrana gelince sepette mi bak
        .alert(Constant.infoText, isPresented: $showAlert) {
            Button(Constant.okey, role: .cancel) {}
        } message: {
            Text(alertText)
        }
    }
}

extension MovieDetailScreen {
    enum Constant {
        static let username = "zaimonur"
        static let giftButtonText = "Hediye Et"
        static let addCartButtonGreen = "Sepete Ekle"
        static let addCartButtonRed = "Vazgeç"
        static let alertText = "Bu film sepetinde görünmüyor."
        static let infoText = "Bilgi"
        static let okey = "Tamam"
    }
}


