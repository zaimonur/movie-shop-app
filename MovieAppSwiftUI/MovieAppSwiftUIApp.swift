//
//  MovieAppSwiftUIApp.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 17.09.2025.
//

import SwiftUI

@main
struct MovieAppSwiftUIApp: App {
    let persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
