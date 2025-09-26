//
//  MovieResponse.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import Foundation

class MoviesResponse: Codable {
    let movies: [Movie]?
}

// Sepeti getir
class CartResponse: Codable {
    let success: Int?
    let message: String?
    let cart: [MovieOrder]?
}

// Genel “işlem sonucu” (ekle/sil)
class ActionResponse: Codable {
    let success: Int?
    let message: String?
}


