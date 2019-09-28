//
//  BookmarksViewController.swift
//  BookPlayer
//
//  Created by Gianni Carlo on 6/2/19.
//  Copyright © 2019 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import Themeable
import UIKit

class BookmarksViewController: UITableViewController {
    var bookmarks: [Bookmark]!
    var didSelectBookmark: ((_ selectedBookmark: Bookmark) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        setUpTheming()
    }

    @IBAction func done(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        let bookmark = self.bookmarks[indexPath.row]

        cell.textLabel?.text = bookmark.title
        cell.detailTextLabel?.text = bookmark.notes
        cell.accessoryType = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectBookmark?(self.bookmarks[indexPath.row])

        self.done(nil)
    }
}

extension BookmarksViewController: Themeable {
    func applyTheme(_ theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
}
