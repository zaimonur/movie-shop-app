//
//  TabBar.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomePageScreen()
            }
            .tabItem{
                Image(systemName: "house.fill")
            }
            NavigationStack {
                SearchScreen()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
            }
            NavigationStack{
                FavoriteMovieScreen()
            }
            .tabItem {
                Image(systemName: "heart.fill")
            }
            CartScreen()
                .tabItem {
                    Image(systemName: "cart")
                }
        }
        .accentColor(AppColors.primary)
        .background(AppColors.dividerBG)
    }
}

#Preview {
    TabBar()
}
