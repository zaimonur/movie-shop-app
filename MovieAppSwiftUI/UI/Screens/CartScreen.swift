//
//  CartScreen.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import SwiftUI
import Kingfisher

private enum AppConfig {
    static let imageBase = URL(string: "http://kasimadalan.pe.hu/movies/images/")!
}

struct CartScreen: View {
    
    // MARK: - Değişkenler
    @StateObject private var vm = CartScreenViewModel()
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorText: String?
    
    private var buyButton: some View {
        Button {
            // satın alma akışını burada başlat
        } label: {
            Text(Constant.buyButtonText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(AppColors.success)
        .foregroundStyle(AppColors.primaryButtonTextColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Computed View
    private var totalPriceText: some View {
        HStack {
            Text(Constant.totalPriceText)
                .font(.headline)
            Spacer()
            Text("\(totalPrice()) ₺")
                .font(.title3.bold())
        }
        .padding(.horizontal, 16)
    }
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.textSecondary)
            Text(Constant.emptyCartText)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text(Constant.emptyCartTextInfo)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    @ViewBuilder
    private var cartScreenContent : some View {
        if vm.items.isEmpty {
            emptyState
        }
        else {
            List {
                ForEach(vm.items, id: \.id) { item in
                    CartRow(item: item)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task { await delete(item) }
                            } label: {
                                Label(Constant.deleteButtonText, systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            
            // Footer: toplam + satın al
            VStack(spacing: 12) {
                totalPriceText
                buyButton
            }
            .background(AppColors.cardBG)
        }
    }
    
    // MARK: - Functions
    //Hesaplama
    // Adet sabit 1 olduğu için orderAmount'ı katmıyoruz.
    private func totalPrice() -> Int {
        vm.items.reduce(0) { $0 + ( $1.price ?? 0 ) }
    }
    //İşlemler
    private func reload() async {
        isLoading = true
        defer { isLoading = false }
        await vm.getCartMovie(userName: Constant.username)
    }
    private func delete(_ item: MovieOrder) async {
        isLoading = true
        defer { isLoading = false }
        await vm.deleteCartMovie(id: item.cartId ?? -1, userName: item.userName ?? Constant.username)
        await vm.getCartMovie(userName: item.userName ?? Constant.username)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            cartScreenContent
        }
        .navigationTitle(Constant.navigationTitleText)
        .toolbarTitleDisplayMode(.inline)
        .task { await reload() }
        .overlay { if isLoading { ProgressView().scaleEffect(1.1) } }
        .alert(Constant.alertText, isPresented: $showError) {
            Button(Constant.okeyButtonText, role: .cancel) { errorText = nil }
        } message: {
            Text(errorText ?? Constant.alertText)
        }
        .background(AppColors.appBG.ignoresSafeArea())
    }
}

// MARK: - Satır Görünümü
struct CartRow: View {
    let item: MovieOrder
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            KFImage.url(item.imageURL)
                .placeholder { Color.gray.opacity(0.15) }
                .retry(maxCount: 2, interval: .seconds(1))
                .onFailureImage(UIImage(systemName: "photo"))
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name ?? "—")
                    .font(.subheadline.bold())
                    .lineLimit(2)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("\(item.price ?? 0) ₺")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.primary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - MovieOrder yardımcıları
extension MovieOrder {
    // Identifiable güvenliği
    var id: Int { cartId ?? ((name?.hashValue ?? 0) ^ (year ?? 0)) }
    
    // Sepette görselin görünmesi için tam URL üret
    var imageURL: URL? {
        guard let raw = image?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return URL(string: raw)
        }
        let path = raw.hasPrefix("/") ? String(raw.dropFirst()) : raw
        return AppConfig.imageBase.appendingPathComponent(path)
    }
}

extension CartScreen {
    enum Constant {
        static let username = "zaimonur"
        static let navigationTitleText = "Sepet"
        static let alertText = "Hata"
        static let okeyButtonText = "Tamam"
        static let deleteButtonText = "Sil"
        static let emptyCartText = "Sepetiniz boş."
        static let emptyCartTextInfo = "Sepetinizde ürün bulunmamaktadır."
        static let totalPriceText = "Toplam Fiyat"
        static let buyButtonText = "Satın Al"
    }
}

// MARK: - Preview
#Preview {
    CartScreen()
}
