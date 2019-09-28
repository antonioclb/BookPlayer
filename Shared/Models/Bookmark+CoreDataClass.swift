//
//  Bookmark+CoreDataClass.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 6/1/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Bookmark)
public class Bookmark: NSManagedObject {
    convenience init(at position: Double, title: String, notes: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context)!

        self.init(entity: entity, insertInto: context)
        self.title = title
        self.notes = notes
        self.position = position
    }
}
