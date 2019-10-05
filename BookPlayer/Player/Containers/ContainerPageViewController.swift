//
//  ContainerPageViewController.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 10/3/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import UIKit

class ContainerPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var currentBook: Book!

    var playerViewController: PlayerViewController!
    var chapterNavViewController: UINavigationController!
    var chaptersViewController: ChaptersViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        let storyboard = UIStoryboard(name: "Player", bundle: nil)

        guard
            let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController,
            let chapterNavVC = storyboard.instantiateViewController(withIdentifier: "NavigationChaptersViewController") as? UINavigationController,
            let chapterVC = chapterNavVC.children.first as? ChaptersViewController else {
            fatalError("Couldn't instantiate player and chapter controllers")
        }

        playerVC.currentBook = self.currentBook
        playerVC.didPressChapters = {
            self.setViewControllers([chapterNavVC], direction: .reverse, animated: true, completion: nil)
        }
        chapterVC.currentBook = self.currentBook
        chapterVC.didSelectChapter = { selectedChapter in
            defer {
                self.setViewControllers([playerVC], direction: .forward, animated: true, completion: nil)
            }
            guard let chapter = selectedChapter else { return }
            // Don't set the chapter, set the new time which will set the chapter in didSet
            // Add a fraction of a second to make sure we start after the end of the previous chapter
            PlayerManager.shared.jumpTo(chapter.start + 0.01)
        }

        self.playerViewController = playerVC
        self.chapterNavViewController = chapterNavVC
        self.chaptersViewController = chapterVC

        NotificationCenter.default.addObserver(self, selector: #selector(self.bookChange(_:)), name: .bookChange, object: nil)

        self.setViewControllers([playerVC], direction: .forward, animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .playerDismissed, object: nil, userInfo: nil)
    }

    @objc func bookChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let book = userInfo["book"] as? Book
        else {
            return
        }

        self.currentBook = book

        self.playerViewController.setNewBook(book)
        self.chaptersViewController.setNewBook(book)

        // Transition back to player if no chapters found on new book

        if !book.hasChapters {
            self.setViewControllers([self.playerViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is PlayerViewController, self.currentBook.hasChapters {
            return self.chapterNavViewController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is UINavigationController {
            return self.playerViewController
        }
        return nil
    }
}

extension ContainerPageViewController: UIPageViewControllerDelegate {}
