//
//  MovieOrder.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import Foundation

class MovieOrder: Identifiable, Codable {
    var cartId: Int?
    var name: String?
    var image: String?
    var price: Int?
    var category: String?
    var rating: Double?
    var year: Int?
    var director: String?
    var description: String?
    var orderAmount: Int?
    var userName: String? = "zaimonur"
    
    init(cartId: Int?, name: String?, image: String?, price: Int?, category: String?, rating: Double?, year: Int?, director: String?, description: String?, orderAmount: Int?){
        self.cartId = cartId
        self.name = name
        self.image = image
        self.price = price
        self.category = category
        self.rating = rating
        self.year = year
        self.director = director
        self.description = description
        self.orderAmount = orderAmount
        userName = "zaimonur"
    }
}
