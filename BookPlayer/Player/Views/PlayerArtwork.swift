//
//  ArtworkView.swift
//  BookPlayer
//
//  Created by Florian Pichler on 22.06.18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import UIKit

class PlayerArtwork: UIView, UIGestureRecognizerDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet private weak var artworkImage: BPArtworkView!

    var cornerRadius: CGFloat = 8.0

    var book: LibraryItem? {
        didSet {
            self.artworkImage.image = self.book?.artwork
        }
    }

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }

    private func setup() {
        self.backgroundColor = .clear

        // Load & setup xib
        Bundle.main.loadNibNamed("ArtworkControl", owner: self, options: nil)

        self.addSubview(self.contentView)

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.artworkImage.clipsToBounds = true
        self.artworkImage.contentMode = .scaleAspectFit
        self.artworkImage.layer.cornerRadius = self.cornerRadius

        // View & Subviews

        let shadowSpread: CGFloat = 15.0

        // TODO: Get the correct bounds after .scaleAspectFit
        let spreadRect = self.artworkImage.bounds.inset(by: UIEdgeInsets(top: CGFloat(shadowSpread), left: shadowSpread, bottom: shadowSpread, right: shadowSpread))

        self.layer.cornerRadius = self.cornerRadius
        self.layer.masksToBounds = false

        self.layer.shadowPath = CGPath(roundedRect: spreadRect, cornerWidth: self.cornerRadius, cornerHeight: self.cornerRadius, transform: .none)
        self.layer.shadowRadius = 23.5
        self.layer.shadowOffset = CGSize(width: shadowSpread, height: shadowSpread + 5.0 / 8.0 * self.cornerRadius)
        self.layer.shadowOpacity = 1.0

        // TODO: Not sure why this doesn't work
        self.layer.shadowColor = self.book?.shadowColor.cgColor
    }
}
