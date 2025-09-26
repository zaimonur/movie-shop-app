//
//  Movie.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import Foundation

class Movie: Identifiable, Codable {
    var id: Int?
    var name: String?
    var image: String?
    var price: Int?
    var category: String?
    var rating: Double?
    var year: Int?
    var director: String?
    var description: String?
    
    init(id: Int, name: String, image: String, price: Int, category: String, rating: Double, year: Int, director: String, description: String){
        self.id = id
        self.name = name
        self.image = image
        self.price = price
        self.category = category
        self.rating = rating
        self.year = year
        self.director = director
        self.description = description
    }
}
