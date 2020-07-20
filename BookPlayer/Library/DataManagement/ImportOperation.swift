//
//  BookOperation.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 8/30/18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import Foundation
import IDZSwiftCommonCrypto
import ZipArchive

/**
 Process files located at a specific `URL`, renames it with the hash and moves it to the specified destination folder.
 The new file maintains the extension of the original `URL`
 */

public class ImportOperation: Operation {
    public let files: [FileItem]

    init(files: [FileItem]) {
        self.files = files
    }

    func getInfo() -> [String: String] {
        var dictionary = [String: Int]()
        for file in self.files {
            dictionary[file.originalUrl.pathExtension] = (dictionary[file.originalUrl.pathExtension] ?? 0) + 1
        }
        var finalInfo = [String: String]()
        for (key, value) in dictionary {
            finalInfo[key] = "\(value)"
        }

        return finalInfo
    }

    func handleZip(file: FileItem) {
        guard file.originalUrl.pathExtension == "zip" else { return }

        // Unzip to a temp directory
        let tempURL = file.destinationFolder.appendingPathComponent("tmp")

        try? FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)

        SSZipArchive.unzipFile(atPath: file.originalUrl.path, toDestination: tempURL.path, progressHandler: nil) { _, success, error in
            defer {
                // Delete original zip file
                try? FileManager.default.removeItem(at: file.originalUrl)
            }

            guard success else {
                print("Extraction of ZIP archive failed with error:\(String(describing: error))")
                return
            }

            let tempItem = FileItem(originalUrl: tempURL, processedUrl: nil, destinationFolder: file.destinationFolder)

            self.handleDirectory(file: tempItem)
        }
    }

    func handleDirectory(file: FileItem) {
        let documentsURL = DataManager.getDocumentsFolderURL()
        let destinationURL = documentsURL.appendingPathComponent(file.originalUrl.lastPathComponent)

        try? FileManager.default.moveItem(at: file.originalUrl, to: destinationURL)
        try? FileManager.default.removeItem(at: file.originalUrl)
    }

    public override func main() {
        for file in self.files {
            NotificationCenter.default.post(name: .processingFile, object: nil, userInfo: ["filename": file.originalUrl.lastPathComponent])

            guard file.originalUrl.pathExtension != "zip" else {
                self.handleZip(file: file)
                continue
            }

            guard let attributes = try? FileManager.default.attributesOfItem(atPath: file.originalUrl.path) else {
                continue
            }

            if let type = attributes[.type] as? FileAttributeType, type == .typeDirectory {
                self.handleDirectory(file: file)
                continue
            }

            guard FileManager.default.fileExists(atPath: file.originalUrl.path),
                let inputStream = InputStream(url: file.originalUrl) else {
                continue
            }

            inputStream.open()

            autoreleasepool {
                let digest = Digest(algorithm: .md5)

                while inputStream.hasBytesAvailable {
                    var inputBuffer = [UInt8](repeating: 0, count: 1024)
                    inputStream.read(&inputBuffer, maxLength: inputBuffer.count)
                    _ = digest.update(byteArray: inputBuffer)
                }

                inputStream.close()

                let finalDigest = digest.final()

                let hash = hexString(fromArray: finalDigest)
                let ext = file.originalUrl.pathExtension
                let filename = file.originalUrl.deletingPathExtension().lastPathComponent + hash + ".\(ext)" // hash + ".\(ext)"
                print(filename)
                let destinationURL = file.destinationFolder.appendingPathComponent(filename)
                print(destinationURL)

                do {
                    if !FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.moveItem(at: file.originalUrl, to: destinationURL)
                        try (destinationURL as NSURL).setResourceValue(URLFileProtection.none, forKey: .fileProtectionKey)
                        if let derp = hash.data(using: .utf8) {
                            print("setting extended attribute")
                            try destinationURL.setExtendedAttribute(data: derp, forName: "com.tortugapower.audiobookplayer.process.status")
                            print("set successful")
                        }
                    } else {
                        try FileManager.default.removeItem(at: file.originalUrl)
                    }
                } catch {
                    fatalError("Error: \(error). Fail to move file from \(file.originalUrl) to \(destinationURL)")
                }

                file.processedUrl = destinationURL
            }
        }
    }
}
