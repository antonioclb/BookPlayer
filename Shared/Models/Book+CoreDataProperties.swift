//
//  Book+CoreDataProperties.swift
//  BookPlayerKit
//
//  Created by Gianni Carlo on 4/23/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//
//

import CoreData
import Foundation

extension Book {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var author: String!
    @NSManaged public var ext: String!
    @NSManaged public var usesDefaultArtwork: Bool
    @NSManaged public var chapters: NSOrderedSet?
    @NSManaged public var bookmarks: NSOrderedSet?
    @NSManaged public var playlist: Playlist?
    @NSManaged public var artworkColors: Theme!
    @NSManaged public var lastPlayed: Library?
}

// MARK: Generated accessors for chapters

extension Book {
    @objc(insertObject:inChaptersAtIndex:)
    @NSManaged public func insertIntoChapters(_ value: Chapter, at idx: Int)

    @objc(removeObjectFromChaptersAtIndex:)
    @NSManaged public func removeFromChapters(at idx: Int)

    @objc(insertChapters:atIndexes:)
    @NSManaged public func insertIntoChapters(_ values: [Chapter], at indexes: NSIndexSet)

    @objc(removeChaptersAtIndexes:)
    @NSManaged public func removeFromChapters(at indexes: NSIndexSet)

    @objc(replaceObjectInChaptersAtIndex:withObject:)
    @NSManaged public func replaceChapters(at idx: Int, with value: Chapter)

    @objc(replaceChaptersAtIndexes:withChapters:)
    @NSManaged public func replaceChapters(at indexes: NSIndexSet, with values: [Chapter])

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: Chapter)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: Chapter)

    @objc(addChapters:)
    @NSManaged public func addToChapters(_ values: NSOrderedSet)

    @objc(removeChapters:)
    @NSManaged public func removeFromChapters(_ values: NSOrderedSet)

    @objc(insertObject:inBookmarksAtIndex:)
    @NSManaged public func insertIntoBookmarks(_ value: Bookmark, at idx: Int)

    @objc(removeObjectFromBookmarksAtIndex:)
    @NSManaged public func removeFromBookmarks(at idx: Int)

    @objc(insertBookmarks:atIndexes:)
    @NSManaged public func insertIntoBookmarks(_ values: [Bookmark], at indexes: NSIndexSet)

    @objc(removeBookmarksAtIndexes:)
    @NSManaged public func removeFromBookmarks(at indexes: NSIndexSet)

    @objc(replaceObjectInBookmarksAtIndex:withObject:)
    @NSManaged public func replaceBookmarks(at idx: Int, with value: Bookmark)

    @objc(replaceBookmarksAtIndexes:withBookmarks:)
    @NSManaged public func replaceBookmarks(at indexes: NSIndexSet, with values: [Bookmark])

    @objc(addBookmarksObject:)
    @NSManaged public func addToBookmarks(_ value: Bookmark)

    @objc(removeBookmarksObject:)
    @NSManaged public func removeFromBookmarks(_ value: Bookmark)

    @objc(addBookmarks:)
    @NSManaged public func addToBookmarks(_ values: NSOrderedSet)

    @objc(removeBookmarks:)
    @NSManaged public func removeFromBookmarks(_ values: NSOrderedSet)
}
