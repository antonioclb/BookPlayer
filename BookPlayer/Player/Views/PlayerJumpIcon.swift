//
//  PlayerJumpIconView.swift
//  BookPlayer
//
//  Created by Florian Pichler on 22.04.18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import UIKit

class PlayerJumpIcon: UIView {
    fileprivate var backgroundImageView: UIImageView!
    fileprivate var label: UILabel!

    var onTap: (() -> Void)?

    var backgroundImage: UIImage = UIImage()

    var title: String = "" {
        didSet {
            self.label.text = self.title
        }
    }

    override var tintColor: UIColor! {
        didSet {
            self.backgroundImageView.tintColor = self.tintColor
            self.label.textColor = self.tintColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    fileprivate func setup() {
        self.backgroundColor = .clear

        self.backgroundImageView = UIImageView(image: self.backgroundImage)
        self.backgroundImageView.tintColor = self.tintColor

        self.label = UILabel()
        self.label.allowsDefaultTighteningForTruncation = true
        self.label.adjustsFontSizeToFitWidth = true
        self.label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        self.label.textAlignment = .center
        self.label.textColor = self.tintColor
        self.label.accessibilityTraits = .button
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.label)

        let controlTap = UILongPressGestureRecognizer(target: self, action: #selector(self.tapControl))
        controlTap.minimumPressDuration = 0

        self.addGestureRecognizer(controlTap)
    }

    override func layoutSubviews() {
        self.label.frame = self.bounds.insetBy(dx: 10.0, dy: 10.0)
        self.backgroundImageView.center = self.label.center
    }

    @objc private func tapControl(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began
            || gestureRecognizer.state == .ended else {
            return
        }

        guard gestureRecognizer.state == .ended else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.alpha = 0.5
            }, completion: { _ in
                self.onTap?()

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            })

            return
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.alpha = 1
        }, completion: nil)
    }
}

class PlayerJumpIconForward: PlayerJumpIcon {
    override var backgroundImage: UIImage {
        get {
            return #imageLiteral(resourceName: "icon_player_jump_forward")
        }
        set {
            super.backgroundImage = newValue
        }
    }

    override func setup() {
        super.setup()

        self.title = "+\(Int(PlayerManager.shared.forwardInterval.rounded()))"
        self.label.accessibilityLabel = VoiceOverService.fastForwardText()
    }
}

class PlayerJumpIconRewind: PlayerJumpIcon {
    override var backgroundImage: UIImage {
        get {
            return #imageLiteral(resourceName: "icon_player_jump_rewind")
        }
        set {
            super.backgroundImage = newValue
        }
    }

    override func setup() {
        super.setup()

        self.title = "−\(Int(PlayerManager.shared.rewindInterval.rounded()))"
        self.label.accessibilityLabel = VoiceOverService.rewindText()
    }
}
