//
//  Favorite.swift
//  MovieAppSwiftUI
//
//  Created by Onur Zaim on 21.09.2025.
//

import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {
    // createdAt alanına modelde "Default: Now" vermediysen
    // ekleme anında otomatik bugünün tarihini atar.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        if self.value(forKey: "createdAt") == nil {
            self.setValue(Date(), forKey: "createdAt")
        }
    }
}

extension Favorite {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    // MARK: - Core Data Properties
    @NSManaged public var movieId: Int64
    @NSManaged public var createdAt: Date
}

extension Favorite {
    // Kullanışlı yardımcılar (opsiyonel)

    // Belirli bir film ID'si için tek kaydı getirir
    @nonobjc public class func fetchRequest(movieId: Int64) -> NSFetchRequest<Favorite> {
        let req = NSFetchRequest<Favorite>(entityName: "Favorite")
        req.predicate = NSPredicate(format: "movieId == %d", movieId)
        req.fetchLimit = 1
        return req
    }

    // Tüm favorileri tarihe göre (yeni → eski) getirir
    @nonobjc public class func fetchAllSorted() -> NSFetchRequest<Favorite> {
        let req = NSFetchRequest<Favorite>(entityName: "Favorite")
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return req
    }
}
