//
//  PlayerControlsViewController.swift
//  BookPlayer
//
//  Created by Florian Pichler on 05.04.18.
//  Copyright © 2018 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import Themeable
import UIKit

class PlayerSliderControlsViewController: PlayerContainerViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var chapterTitleLabel: UILabel!
    @IBOutlet private weak var progressSlider: ProgressSlider!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var maxTimeButton: UIButton!
    @IBOutlet private weak var progressButton: UIButton!

    var book: Book? {
        didSet {
            guard let book = self.book, !book.isFault else { return }

            self.setProgress()
            applyTheme(self.themeProvider.currentTheme)
        }
    }

    public lazy var customChapterRotor = UIAccessibilityCustomRotor(name: "Skip Chapters") { (predicate) -> UIAccessibilityCustomRotorItemResult? in

        guard let currentBook = self.book, currentBook.hasChapters else { return nil }

        let forward: Bool = (predicate.searchDirection == .next)

        guard let nextChapter = forward
            ? currentBook.nextChapter()
            : currentBook.previousChapter()
        else { return nil }

        PlayerManager.shared.jumpTo(nextChapter.start + 0.01)

        return UIAccessibilityCustomRotorItemResult(targetElement: self.progressButton.titleLabel!, targetRange: nil)
    }

    private var prefersChapterContext = UserDefaults.standard.bool(forKey: Constants.UserDefaults.chapterContextEnabled.rawValue)

    private var prefersRemainingTime = UserDefaults.standard.bool(forKey: Constants.UserDefaults.remainingTimeEnabled.rawValue)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPlayback), name: .bookPlaying, object: nil)
    }

    // MARK: - Notification Handlers

    @objc func onPlayback() {
        self.setProgress()
    }

    // MARK: - Helpers

    private func setProgress() {
        guard let book = self.book, !book.isFault else {
            self.progressButton.setTitle("", for: .normal)

            return
        }

        self.chapterTitleLabel.isHidden = !book.hasChapters

        if !self.progressSlider.isTracking {
            self.currentTimeLabel.text = self.formatTime(book.currentTimeInContext(self.prefersChapterContext))
            self.currentTimeLabel.accessibilityLabel = String(describing: String.localizedStringWithFormat("voiceover_chapter_time_title".localized, VoiceOverService.secondsToMinutes(book.currentTimeInContext(self.prefersChapterContext))))

            let maxTimeInContext = book.maxTimeInContext(self.prefersChapterContext, self.prefersRemainingTime)
            self.maxTimeButton.setTitle(self.formatTime(maxTimeInContext), for: .normal)
            let prefix = self.prefersRemainingTime
                ? "chapter_time_remaining_title".localized
                : "chapter_duration_title".localized
            self.maxTimeButton.accessibilityLabel = String(describing: prefix + VoiceOverService.secondsToMinutes(maxTimeInContext))
        }

        guard
            self.prefersChapterContext,
            book.hasChapters,
            let chapters = book.chapters,
            let currentChapter = book.currentChapter else {
            if !self.progressSlider.isTracking {
                self.progressButton.setTitle("\(Int(round(book.progress * 100)))%", for: .normal)

                self.progressSlider.value = Float(book.progress)
                self.progressSlider.setNeedsDisplay()
                let prefix = self.prefersRemainingTime
                    ? "book_time_remaining_title".localized
                    : "book_duration_title".localized
                let maxTimeInContext = book.maxTimeInContext(self.prefersChapterContext, self.prefersRemainingTime)
                self.maxTimeButton.accessibilityLabel = String(describing: prefix + VoiceOverService.secondsToMinutes(maxTimeInContext))
            }

            return
        }

        self.chapterTitleLabel.text = currentChapter.title
        self.progressButton.isHidden = false
        self.progressButton.setTitle(String.localizedStringWithFormat("player_chapter_description".localized, currentChapter.index, chapters.count), for: .normal)

        if !self.progressSlider.isTracking {
            self.progressSlider.value = Float((book.currentTime - currentChapter.start) / currentChapter.duration)
            self.progressSlider.setNeedsDisplay()
        }
    }

    // MARK: - Storyboard Actions

    var chapterBeforeSliderValueChange: Chapter?

    @IBAction func toggleMaxTime(_ sender: UIButton) {
        self.prefersRemainingTime = !self.prefersRemainingTime
        UserDefaults.standard.set(self.prefersRemainingTime, forKey: Constants.UserDefaults.remainingTimeEnabled.rawValue)
        self.setProgress()
    }

    @IBAction func toggleProgressState(_ sender: UIButton) {
        self.prefersChapterContext = !self.prefersChapterContext
        UserDefaults.standard.set(self.prefersChapterContext, forKey: Constants.UserDefaults.chapterContextEnabled.rawValue)
        self.setProgress()
    }

    @IBAction func sliderDown(_ sender: UISlider, event: UIEvent) {
        self.chapterBeforeSliderValueChange = self.book?.currentChapter
    }

    @IBAction func sliderUp(_ sender: UISlider, event: UIEvent) {
        guard let book = self.book, !book.isFault else {
            return
        }

        // Setting progress here instead of in `sliderValueChanged` to only register the value when the interaction
        // has ended, while still previwing the expected new time and progress in labels and display
        var newTime = TimeInterval(sender.value) * book.duration

        if self.prefersChapterContext, let currentChapter = book.currentChapter {
            newTime = currentChapter.start + TimeInterval(sender.value) * currentChapter.duration
        }

        PlayerManager.shared.jumpTo(newTime)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider, event: UIEvent) {
        // This should be in ProgressSlider, but how to achieve that escapes my knowledge
        self.progressSlider.setNeedsDisplay()

        guard let book = self.book, !book.isFault else {
            return
        }

        var newTimeToDisplay = TimeInterval(sender.value) * book.duration

        if self.prefersChapterContext, let currentChapter = self.chapterBeforeSliderValueChange {
            newTimeToDisplay = TimeInterval(sender.value) * currentChapter.duration
        }

        self.currentTimeLabel.text = self.formatTime(newTimeToDisplay)

        if !book.hasChapters || !self.prefersChapterContext {
            self.progressButton.setTitle("\(Int(round(sender.value * 100)))%", for: .normal)
        }

        if self.prefersRemainingTime {
            let durationTimeInContext = book.durationTimeInContext(self.prefersChapterContext)
            self.maxTimeButton.setTitle(self.formatTime(newTimeToDisplay - durationTimeInContext), for: .normal)
        }
    }
}

extension PlayerSliderControlsViewController: Themeable {
    func applyTheme(_ theme: Theme) {
        self.chapterTitleLabel.textColor = theme.primaryColor
        self.progressSlider.minimumTrackTintColor = theme.highlightColor
        self.progressSlider.maximumTrackTintColor = theme.lightHighlightColor

        self.currentTimeLabel.textColor = theme.primaryColor
        self.maxTimeButton.setTitleColor(theme.primaryColor, for: .normal)
        self.progressButton.setTitleColor(theme.primaryColor, for: .normal)
    }
}
