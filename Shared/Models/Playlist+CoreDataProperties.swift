//
//  Playlist+CoreDataProperties.swift
//  BookPlayerKit
//
//  Created by Gianni Carlo on 4/23/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//
//

import CoreData
import Foundation

extension Playlist {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @nonobjc public class func find(with identifier: String, context: NSManagedObjectContext) -> Playlist? {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        request.predicate = NSPredicate(format: "identifier = %@", identifier)

        return try? context.fetch(request).first
    }

    @nonobjc public class func find(at path: String, context: NSManagedObjectContext) -> Playlist? {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        request.predicate = NSPredicate(format: "path = %@", path)

        return try? context.fetch(request).first
    }

    @NSManaged public var desc: String!
    @NSManaged public var books: NSOrderedSet?
    @NSManaged public var parentPlaylist: Playlist?
    @NSManaged public var items: NSOrderedSet?
}

// MARK: Generated accessors for books

extension Playlist {
    @objc(insertObject:inBooksAtIndex:)
    @NSManaged public func insertIntoBooks(_ value: Book, at idx: Int)

    @objc(removeObjectFromBooksAtIndex:)
    @NSManaged public func removeFromBooks(at idx: Int)

    @objc(insertBooks:atIndexes:)
    @NSManaged public func insertIntoBooks(_ values: [Book], at indexes: NSIndexSet)

    @objc(removeBooksAtIndexes:)
    @NSManaged public func removeFromBooks(at indexes: NSIndexSet)

    @objc(replaceObjectInBooksAtIndex:withObject:)
    @NSManaged public func replaceBooks(at idx: Int, with value: Book)

    @objc(replaceBooksAtIndexes:withBooks:)
    @NSManaged public func replaceBooks(at indexes: NSIndexSet, with values: [Book])

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSOrderedSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSOrderedSet)

    @objc(insertObject:inItemsAtIndex:)
    @NSManaged public func insertIntoItems(_ value: LibraryItem, at idx: Int)

    @objc(removeObjectFromItemsAtIndex:)
    @NSManaged public func removeFromItems(at idx: Int)

    @objc(insertItems:atIndexes:)
    @NSManaged public func insertIntoItems(_ values: [LibraryItem], at indexes: NSIndexSet)

    @objc(removeItemsAtIndexes:)
    @NSManaged public func removeFromItems(at indexes: NSIndexSet)

    @objc(replaceObjectInItemsAtIndex:withObject:)
    @NSManaged public func replaceItems(at idx: Int, with value: LibraryItem)

    @objc(replaceItemsAtIndexes:withItems:)
    @NSManaged public func replaceItems(at indexes: NSIndexSet, with values: [LibraryItem])

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: LibraryItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: LibraryItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSOrderedSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSOrderedSet)
}
