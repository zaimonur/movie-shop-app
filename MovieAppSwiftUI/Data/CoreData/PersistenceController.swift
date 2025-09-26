//
//  PersistenceController.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 21.09.2025.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(containerName: String = "MovieAppModel") {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData yüklenemedi: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    //Helper
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do { try context.save() }
            catch { print("CoreData save error:", error) }
        }
    }
}

