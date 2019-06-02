//
//  Bookmark+CoreDataProperties.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 6/1/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//
//

import Foundation
import CoreData


extension Bookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }

    @NSManaged public var title: String
    @NSManaged public var notes: String
    @NSManaged public var position: Double
    @NSManaged public var book: Book?

}
