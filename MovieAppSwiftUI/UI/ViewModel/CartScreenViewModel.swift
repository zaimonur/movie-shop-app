//
//  CartScreenViewModel.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 21.09.2025.
//

import Foundation

@MainActor
class CartScreenViewModel: ObservableObject {
    private let repository = MovieRepository()
    @Published var items: [MovieOrder] = []

    // userName parametresini kullan
    func cartAddMovie(
        name: String, image: String, price: Int, category: String,
        rating: Double, year: Int, director: String, description: String,
        orderAmount: Int, userName: String
    ) async {
        do {
            _ = try await repository.cartAddMovie(
                name: name, image: image, price: price, category: category,
                rating: rating, year: year, director: director,
                description: description, orderAmount: orderAmount, userName: userName
            )
        }
        catch {
            print("cartAddMovie error:", error)
        }
    }

    func getCartMovie(userName: String) async {
        do {
            let list = try await repository.getCartMovie(userName: userName)
            items = list                              
        }
        catch {
            print("getCartMovie error:", error)
        }
    }

    func deleteCartMovie(id: Int, userName: String) async {
        do {
            _ = try await repository.deleteCart(cartId: id, userName: userName)
            items.removeAll { ($0.cartId ?? -1) == id }
        }
        catch
        { print("deleteCartMovie error:", error)
        }
    }
    
    //toplam fiyat
    var totalPrice: Int {
        items.reduce(0) { $0 + (($1.price ?? 0) * ($1.orderAmount ?? 0)) }
    }
}

