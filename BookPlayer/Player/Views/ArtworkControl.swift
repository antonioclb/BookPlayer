//
//  ArtworkView.swift
//  BookPlayer
//
//  Created by Florian Pichler on 22.06.18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import UIKit

class ArtworkControl: UIView, UIGestureRecognizerDelegate {
    @IBOutlet var contentView: UIView!

    @IBOutlet private weak var artworkImage: BPArtworkView!
    @IBOutlet weak var artworkOverlay: UIView!
    @IBOutlet weak var artworkWidth: NSLayoutConstraint!
    @IBOutlet weak var artworkHeight: NSLayoutConstraint!

    var artwork: UIImage? {
        get {
            return self.artworkImage.image
        }

        set {
            self.artworkImage.image = newValue
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
        self.setupAccessibilityLabels()
    }

    private func setup() {
        self.backgroundColor = .clear

        // Load & setup xib
        Bundle.main.loadNibNamed("ArtworkControl", owner: self, options: nil)

        self.addSubview(self.contentView)

        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // View & Subviews
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 12.0

        self.artworkImage.clipsToBounds = false
        self.artworkImage.contentMode = .scaleAspectFit
        self.artworkImage.layer.cornerRadius = 6.0
        self.artworkImage.layer.masksToBounds = true
        self.artworkImage.layer.borderColor = UIColor.clear.cgColor

        self.artworkOverlay.clipsToBounds = false
        self.artworkOverlay.contentMode = .scaleAspectFit
        self.artworkOverlay.layer.cornerRadius = 6.0
        self.artworkOverlay.layer.masksToBounds = true
    }

    // Voiceover
    private func setupAccessibilityLabels() {
//        isAccessibilityElement = false
//        self.rewindIcon.accessibilityLabel = VoiceOverService.rewindText()
//        self.forwardIcon.accessibilityLabel = VoiceOverService.fastForwardText()
//        accessibilityElements = [
//            playPauseButton as Any,
//            rewindIcon as Any,
//            forwardIcon as Any
//        ]
    }
}
