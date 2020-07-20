//
//  DataManager+BookPlayer.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 4/23/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//

import AVFoundation
import BookPlayerKit
import CoreData
import Foundation
import IDZSwiftCommonCrypto
import UIKit
import ZipArchive

extension DataManager {
    static let importer = ImportManager()
    static let queue = OperationQueue()

    // MARK: - Operations

    public class func start(_ operation: Operation) {
        self.queue.addOperation(operation)
    }

    class func isProcessingFiles() -> Bool {
        return !self.queue.operations.isEmpty
    }

    class func countOfProcessingFiles() -> Int {
        var count = 0
        // swiftlint:disable force_cast
        for operation in self.queue.operations as! [ImportOperation] {
            count += operation.files.count
        }
        // swiftlint:enable force_cast
        return count
    }

    // MARK: - Core Data stack

    public class func migrateStack() throws {
        let name = "BookPlayer"
        let container = NSPersistentContainer(name: name)
        let psc = container.persistentStoreCoordinator

        let oldStoreUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
            .appendingPathComponent("\(name).sqlite")

        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]

        guard let oldStore = try? psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: oldStoreUrl, options: options) else {
            // couldn't load old store
            return
        }

        try psc.migratePersistentStore(oldStore, to: self.storeUrl, options: nil, withType: NSSQLiteStoreType)
    }

    // MARK: - File processing

    /**
     Remove file protection for processed folder so that when the app is on the background and the iPhone is locked, autoplay still works
     */
    public class func makeFilesPublic() {
        let processedFolder = self.getProcessedFolderURL()

        guard let files = self.getFiles(from: processedFolder) else { return }

        for file in files {
            self.makeFilePublic(file as NSURL)
        }
    }

    /**
     Remove file protection for one file
     */
    class func makeFilePublic(_ file: NSURL) {
        try? file.setResourceValue(URLFileProtection.none, forKey: .fileProtectionKey)
    }

    /**
     Get url of files in a directory

     - Parameter folder: The folder from which to get all the files urls
     - Returns: Array of file-only `URL`, directories are excluded. It returns `nil` if the folder is empty.
     */
    public class func getFiles(from folder: URL) -> [URL]? {
        // Get reference of all the files located inside the Documents folder
        guard let urls = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants) else {
            return nil
        }

        return filterFiles(urls)
    }

    /**
     Filter out folders from file URLs.
     */
    private class func filterFiles(_ urls: [URL]) -> [URL] {
        return urls.filter { !$0.hasDirectoryPath }
    }

    /**
     Notifies the ImportManager about the new file
     - Parameter origin: File original location
     */
    public class func processFile(at origin: URL) {
        self.processFile(at: origin, destinationFolder: self.getDocumentsFolderURL())
    }

    /**
     Notifies the ImportManager about the new file
     - Parameter origin: File original location
     - Parameter destinationFolder: File final location
     */
    class func processFile(at origin: URL, destinationFolder: URL) {
        self.importer.process(origin, destinationFolder: destinationFolder)
    }

    /**
     Find all the files in the documents folder and send notifications about their existence.
     */
    public class func verifyHierarchy(_ library: Library) -> Bool {
        let documentsFolder = self.getDocumentsFolderURL()

        guard let enumerator = FileManager.default.enumerator(at: documentsFolder,
                                                              includingPropertiesForKeys: [.creationDateKey, .isDirectoryKey],
                                                              options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                  print("directoryEnumerator error at \(url): ", error)
                                                                  return true
		}) else {
            return false
        }

        return self.processFiles(with: enumerator, and: library)
    }

    private class func processFiles(with enumerator: FileManager.DirectoryEnumerator, and library: Library) -> Bool {
        self.saveContext()

        guard let url = enumerator.nextObject() as? URL else { return true }

        // skip inbox and deprecated processed folder
        if url.lastPathComponent == DataManager.inboxFolderName
            || url.lastPathComponent == DataManager.processedFolderName {
            enumerator.skipDescendants()
            return self.processFiles(with: enumerator, and: library)
        }

        // skip zips
        if url.pathExtension == "zip" {
            return self.processFiles(with: enumerator, and: library)
        }

        let parentPlaylist = self.getParentPlaylist(at: url, with: enumerator)
        let path = url.relativePath(to: self.getDocumentsFolderURL())
        print("==== relative path: \(path)")

        // handle already imported files
        if let identifier = url.getAppIdentifier() {
            if url.hasDirectoryPath {
                // verify if book exists in core data, otherwise create it, and add it to parent item (library or playlist)
                let storedPlaylist = Playlist.find(with: identifier, context: self.persistentContainer.viewContext)

                if let storedPlaylist = storedPlaylist {
                    self.insert(storedPlaylist, at: parentPlaylist, or: library)

                    return self.processFiles(with: enumerator, and: library)
                } else {
                    print("=== creating playlist that should already exist")
                    let playlist = self.createPlaylist(from: url, books: [])

                    self.insert(playlist, at: parentPlaylist, or: library)
                }

                return self.processFiles(with: enumerator, and: library)
            } else {
                // verify if book exists in core data, otherwise create it, and add it to parent item (library or playlist)
                let storedBook = Book.find(with: identifier, context: self.persistentContainer.viewContext)

                if let storedBook = storedBook {
                    self.insert(storedBook, at: parentPlaylist, or: library)

                    return self.processFiles(with: enumerator, and: library)
                } else {
                    print("=== creating book that should already exist")
                    self.insertBook(from: url, at: parentPlaylist, or: library)
                }

                return self.processFiles(with: enumerator, and: library)
            }
        }

        // handle new files
        if url.hasDirectoryPath {
            print("=== handling folder, creating playlist: \(url.lastPathComponent)")
            let playlist = self.createPlaylist(from: url, books: [])
            playlist.path = path

            self.insert(playlist, at: parentPlaylist, or: library)

            return self.processFiles(with: enumerator, and: library)
        }

        print("=== creating book from scratch")
        // process book and add it to parent playlist if exists
        self.insertBook(from: url, at: parentPlaylist, or: library)

        return self.processFiles(with: enumerator, and: library)
    }

    private class func getParentPlaylist(at url: URL, with enumerator: FileManager.DirectoryEnumerator) -> Playlist? {
        guard enumerator.level > 0 else { return nil }

        let parent = url.deletingLastPathComponent()

        let parentPath = parent.relativePath(to: self.getDocumentsFolderURL())

        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        request.predicate = NSPredicate(format: "path = %@", parentPath)

        return try? self.persistentContainer.viewContext.fetch(request).first
    }

    private class func getPlaylist(at path: String) -> Playlist? {
        let request: NSFetchRequest<Playlist> = Playlist.fetchRequest()

        request.predicate = NSPredicate(format: "path = %@", path)

        return try? self.persistentContainer.viewContext.fetch(request).first
    }

    private class func insert(_ item: LibraryItem, at playlist: Playlist?, or library: Library) {
        if let playlist = playlist {
            playlist.addToItems(item)
        } else {
            library.addToItems(item)
        }
    }

    private class func insertBook(from url: URL, at playlist: Playlist?, or library: Library) {
        let fileItem = FileItem(originalUrl: url, processedUrl: url, destinationFolder: url)
        let book = Book(from: fileItem, context: self.persistentContainer.viewContext)
        let path = url.relativePath(to: self.getDocumentsFolderURL())
        print("==== relative path: \(path)")
        book.path = path

        // swiftlint:disable force_try
        try! url.setAppIdentifier(book.identifier)

        if let playlist = playlist {
            playlist.addToItems(book)
        } else {
            library.addToItems(book)
        }
    }

    public class func exists(_ book: Book) -> Bool {
        guard let fileURL = book.fileURL else { return false }

        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    // MARK: - Themes

    public class func setupDefaultTheme() {
        let library = self.getLibrary()

        guard library.currentTheme == nil else { return }

        library.currentTheme = self.getLocalThemes().first!

        // prior book artwork colors didn't have a title
        if let books = self.getBooks() {
            for book in books {
                book.artworkColors.title = book.title
            }
        }

        self.saveContext()
    }

    public class func getLocalThemes() -> [Theme] {
        guard
            let themesFile = Bundle.main.url(forResource: "Themes", withExtension: "json"),
            let data = try? Data(contentsOf: themesFile, options: .mappedIfSafe),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves),
            let themeParams = jsonObject as? [[String: Any]]
        else { return [] }

        var themes = [Theme]()

        for themeParam in themeParams {
            let request: NSFetchRequest<Theme> = Theme.fetchRequest()

            guard let predicate = Theme.searchPredicate(themeParam) else { continue }

            request.predicate = predicate

            var theme: Theme!

            if let storedThemes = try? self.persistentContainer.viewContext.fetch(request),
                let storedTheme = storedThemes.first {
                theme = storedTheme
                theme.locked = themeParam["locked"] as? Bool ?? false
            } else {
                theme = Theme(params: themeParam, context: self.persistentContainer.viewContext)
            }

            themes.append(theme)
        }

        return themes
    }

    public class func getExtractedThemes() -> [Theme] {
        let library = self.getLibrary()
        return library.extractedThemes?.array as? [Theme] ?? []
    }

    public class func addExtractedTheme(_ theme: Theme) {
        let library = self.getLibrary()
        library.addToExtractedThemes(theme)
        self.saveContext()
    }

    public class func setCurrentTheme(_ theme: Theme) {
        let library = self.getLibrary()
        library.currentTheme = theme
        DataManager.saveContext()
    }
}
