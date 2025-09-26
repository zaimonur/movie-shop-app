//
//  MovieRepository.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import Foundation

class MovieRepository {
    private var baseURL:String = "http://kasimadalan.pe.hu/movies/"
    
    // MARK: - Load
    func loadMovies() async throws -> [Movie] {
        let apiUrl = "\(baseURL)getAllMovies.php"
        
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }
        
        let (data,_) = try await URLSession.shared.data(from: url)
        let moviesResponse = try JSONDecoder().decode(MoviesResponse.self, from: data)
        
        return moviesResponse.movies!
    }
    
    // MARK: - Search
    func search(searchText:String) async throws -> [Movie] {
        let allMovies = try await loadMovies()
        
        if searchText.isEmpty {
            return allMovies
        }
        
        return allMovies.filter {
            $0.name!.lowercased().contains(searchText.lowercased())
        }
    }
    
    // MARK: - Helpers
        private func formBody(_ params: [String: String]) -> Data? {
            var comps = URLComponents()
            comps.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            return comps.query?.data(using: .utf8)
        }
        private func makeFormRequest(_ url: URL, params: [String: String]) -> URLRequest {
            var r = URLRequest(url: url)
            r.httpMethod = "POST"
            r.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            r.httpBody = formBody(params)
            if let body = r.httpBody, let s = String(data: body, encoding: .utf8) {
                print("➡️ \(url.lastPathComponent) BODY:", s)
            }
            return r
        }

        // MARK: - Insert (senin çalışıyor)
        @discardableResult
        func cartAddMovie(
            name: String, image: String, price: Int,
            category: String, rating: Double, year: Int,
            director: String, description: String,
            orderAmount: Int, userName: String
        ) async throws -> CartResponse {
            let apiUrl = "\(baseURL)insertMovie.php"
            guard let url = URL(string: apiUrl) else { throw URLError(.badURL) }

            // Not: 0 değerleri PHP empty()’ye takılmasın diye mümkünse >0 gönder.
            let req = makeFormRequest(url, params: [
                "name": name,
                "image": image,
                "price": String(price),
                "category": category,
                "rating": String(rating),
                "year": String(year),
                "director": director,
                "description": description,
                "orderAmount": String(orderAmount),
                "userName": userName
            ])

            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(CartResponse.self, from: data)
            print("✅ insertMovie -> success=\(resp.success ?? -1), message=\(resp.message ?? "-")")
            return resp
        }

        // MARK: - GET CART (esnek)
        func getCartMovie(userName: String) async throws -> [MovieOrder] {
            let apiUrl = "\(baseURL)getMovieCart.php"
            guard let url = URL(string: apiUrl) else { throw URLError(.badURL) }

            let req = makeFormRequest(url, params: ["userName": userName])
            let (data, resp) = try await URLSession.shared.data(for: req)

            // Ham body logu (gerçekte ne dönüyor görelim)
            if let http = resp as? HTTPURLResponse { print("⬅️ HTTP \(http.statusCode) getMovieCart") }
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("⬅️ BODY RAW:", raw.isEmpty ? "<empty>" : raw)

            //Boş/invalid ise boş liste
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed == "null" { return [] }

            let dec = JSONDecoder()

            //CartResponse(cart [MovieOrder])
            if let r = try? dec.decode(CartResponse.self, from: data), let list = r.cart {
                print("✅ getMovieCart -> success=\(r.success ?? -1), message=\(r.message ?? "-")")
                return list
            }

            // Dizi direkt geliyorsa: [MovieOrder]
            if let arr = try? dec.decode([MovieOrder].self, from: data) {
                return arr
            }

            //Başka anahtar altında dizi (movies / data / orders / results vs.)
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let anyArray = obj.values.first(where: { $0 is [[String: Any]] }) as? [[String: Any]] {
                let arrData = try JSONSerialization.data(withJSONObject: anyArray)
                if let arr = try? dec.decode([MovieOrder].self, from: arrData) {
                    return arr
                }
            }

            // JSON’ı sanitize etmeyi deneyelim (BOM/HTML kırpma)
            if let sanitized = sanitizedJSONData(data) {
                if let r = try? dec.decode(CartResponse.self, from: sanitized), let list = r.cart {
                    return list
                }
                if let arr = try? dec.decode([MovieOrder].self, from: sanitized) {
                    return arr
                }
                if let obj = try? JSONSerialization.jsonObject(with: sanitized) as? [String: Any],
                   let anyArray = obj.values.first(where: { $0 is [[String: Any]] }) as? [[String: Any]] {
                    let arrData = try JSONSerialization.data(withJSONObject: anyArray)
                    if let arr = try? dec.decode([MovieOrder].self, from: arrData) { return arr }
                }
            }

            // Parse edemiyorsak boş dizi
            return []
        }

        // MARK: - Delete
        @discardableResult
        func deleteCart(cartId: Int, userName: String) async throws -> CartResponse {
            let apiUrl = "\(baseURL)deleteMovie.php"
            guard let url = URL(string: apiUrl) else { throw URLError(.badURL) }

            let req = makeFormRequest(url, params: [
                "cartId": String(cartId),
                "userName": userName
            ])
            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(CartResponse.self, from: data)
            print("✅ deleteMovie -> success=\(resp.success ?? -1), message=\(resp.message ?? "-")")
            return resp
        }

        // MARK: - JSON sanitize (BOM/HTML kırpma)
        private func sanitizedJSONData(_ data: Data) -> Data? {
            var s = String(data: data, encoding: .utf8) ?? ""
            s = s.replacingOccurrences(of: "\u{FEFF}", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard let start = s.firstIndex(where: { $0 == "{" || $0 == "[" }),
                  let end = s.lastIndex(where: { $0 == "}" || $0 == "]" }),
                  start <= end else { return nil }
            let core = String(s[start...end])
            return core.data(using: .utf8)
        }
}
