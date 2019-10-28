//
//  LibraryItem+CoreDataClass.swift
//  BookPlayerKit
//
//  Created by Gianni Carlo on 4/23/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

@objc(LibraryItem)
public class LibraryItem: NSManagedObject, Codable {
    public var shadowColor: UIColor {
        if self.hasDefaultArtwork && self.artworkDefaultColors.count > 3 {
            return self.artworkDefaultColors[3]
        }
        
        return UIColor(red: 50, green:50, blue:50, alpha:1.00)
    }
    
    // Can be converted into something based on the current theme or sets of random colors later
    var artworkDefaultColors: [UIColor] = [
        UIColor(red: 0.20, green:0.53, blue:0.82, alpha:1.00),
        UIColor(red: 0.16, green:0.21, blue:0.58, alpha:1.00),
        UIColor(red: 0.23, green:0.15, blue:0.56, alpha:1.00),
        UIColor(red: 0.16, green:0.21, blue:0.58, alpha:1.00), // shadow color
    ]
    
    public var hasDefaultArtwork: Bool {
        guard
            let artworkData = self.artworkData,
            let _ = UIImage(data: artworkData as Data)
        else {
            return false
        }
        return true
    }
    
    public var artwork: UIImage {
        if let cachedArtwork = self.cachedArtwork {
            return cachedArtwork
        }

        guard
            let artworkData = self.artworkData,
            let image = UIImage(data: artworkData as Data)
        else {
            return self.drawDefaultArtwork()
        }

        self.cachedArtwork = image
        return self.cachedArtwork!
    }
    
    private func drawDefaultArtwork() -> UIImage {
        let drawRect = CGRect(x: 0, y: 0, width: 750, height: 750)
        
        UIGraphicsBeginImageContext(drawRect.size)

        let context = UIGraphicsGetCurrentContext()!
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let backgroundColor = self.artworkDefaultColors[0];
        let radius = sqrt(pow(drawRect.width / 2, 2) + pow(drawRect.height, 2))
        
        context.setFillColor(backgroundColor.cgColor)
        context.fill(drawRect)
        
        if self.artworkDefaultColors.count > 1 {
            let leadingColor = self.artworkDefaultColors[1]
            let leadingGradient = CGGradient(colorsSpace: colorSpace, colors: [
                leadingColor.cgColor,
                leadingColor.withAlphaComponent(0).cgColor,
            ] as CFArray, locations: [0.0, 1.0]);

            context.drawRadialGradient(leadingGradient!, startCenter: CGPoint(x: 0, y: 0), startRadius: 0.0, endCenter: CGPoint(x: 0, y: 0), endRadius: radius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        
        if self.artworkDefaultColors.count > 2 {
            let trailingColor = self.artworkDefaultColors[2];
            
            let trailingGradient = CGGradient(colorsSpace: colorSpace, colors: [
                trailingColor.cgColor,
                trailingColor.withAlphaComponent(0).cgColor,
            ] as CFArray, locations: [0.0, 1.0]);

            context.drawRadialGradient(trailingGradient!, startCenter: CGPoint(x: drawRect.width, y: 0), startRadius: 0.0, endCenter: CGPoint(x: drawRect.width, y: 0), endRadius: radius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!;
    }

    public func info() -> String { return "" }

    var cachedArtwork: UIImage?

    public func getBookToPlay() -> Book? {
        return nil
    }

    public var progress: Double {
        return 1.0
    }

    public func jumpToStart() {}

    public func markAsFinished(_ flag: Bool) {}

    public func encode(to encoder: Encoder) throws {
        fatalError("LibraryItem is an abstract class, override this function in the subclass")
    }

    public required convenience init(from decoder: Decoder) throws {
        fatalError("LibraryItem is an abstract class, override this function in the subclass")
    }
}
