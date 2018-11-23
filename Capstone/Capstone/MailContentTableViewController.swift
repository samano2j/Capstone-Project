//
//  MailContentTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2018-11-19.
//  Copyright © 2018 Christian John. All rights reserved.
//

import UIKit
import SwipeCellKit

class MailContentTableViewController: UITableViewController {
    // MARK: - Variable Declarations
    var emails: [Email] = []
    
    var defaultSwipeOptions = SwipeOptions()
    var swipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    
    var titleStringViaSegue: String!
    
    // MARK: - Types
    
    /// Search State restoration values.
    private enum RestorationKeys: String {
        case viewControllerTitle
        case searchControllerIsActive
        case searchBarText
        case searchBarIsFirstResponder
    }
    
    /// NSPredicate expression keys.
    private enum ExpressionKeys: String {
        case from
        case subject
        case body
    }
    
    private struct SearchControllerRestorableState {
        var wasActive = false
        var wasFirstResponder = false
    }
    
    /** The following 2 properties are set in viewDidLoad(),
     They are implicitly unwrapped optionals because they are used in many other places
     throughout this view controller.
     */
    
    // Search controller to help us with filtering.
    private var searchController: UISearchController!
    
    /// Secondary search results table view.
    private var resultsTableController: MailResultTableViewController!
    
    /// Restoration state for UISearchController
    private var restoredState = SearchControllerRestorableState()

    
    // MARK: - viewDIdLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        ///////////////////////////////////stuffs for search/////////////////////////////////////////////
        resultsTableController = MailResultTableViewController()
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Stop the search bar from always being visible
            navigationItem.hidesSearchBarWhenScrolling = true
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.title = titleStringViaSegue
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true // The default is true. [was false]
        searchController.searchBar.delegate = self  // Monitor when the search button is tapped.
        
        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */
        
        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        view.layoutMargins.left = 32
        
        resetData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell") as! MailCell
        cell.delegate = self
        cell.backgroundView = createSelectedBackgroundView()
        
        let email = emails[indexPath.row]
        cell.fromLabel.text = email.from
        cell.dateLabel.text = email.relativeDateString
        cell.subjectLabel.text = email.subject
        cell.bodyLabel.text = email.body
        cell.unread = email.unread
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let email = emails[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? MailCell {
            let toggleUnreadState = !email.unread
            email.unread = toggleUnreadState
            
            cell.setUnread(toggleUnreadState, animated: true)
        }
    }
    
    // MARK: - Helpers
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
    
    func resetData() {
        emails = mockEmails
        emails.forEach { $0.unread = false }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension MailContentTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension MailContentTableViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
}

// MARK: - UISearchResultsUpdating

extension MailContentTableViewController: UISearchResultsUpdating {
    
    private func findMatches(searchString: String) -> NSCompoundPredicate {
        /** Each searchString creates an OR predicate for: name, yearIntroduced, introPrice.
         Example if searchItems contains "Gladiolus 51.99 2001":
         name CONTAINS[c] "gladiolus"
         name CONTAINS[c] "gladiolus", yearIntroduced ==[c] 2001, introPrice ==[c] 51.99
         name CONTAINS[c] "ginger", yearIntroduced ==[c] 2007, introPrice ==[c] 49.98
         */
        var searchMailsPredicate = [NSPredicate]()
        
        /** Below we use NSExpression represent expressions in our predicates.
         NSPredicate is made up of smaller, atomic parts:
         two NSExpressions (a left-hand value and a right-hand value).
         */
        
        // Name field matching.
        let fromExpression = NSExpression(forKeyPath: ExpressionKeys.from.rawValue)
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let fromSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: fromExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        
        searchMailsPredicate.append(fromSearchComparisonPredicate)
        
        let subjectExpression = NSExpression(forKeyPath: ExpressionKeys.subject.rawValue)
        let subjectSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: subjectExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        
        searchMailsPredicate.append(subjectSearchComparisonPredicate)
        
        let bodyExpression = NSExpression(forKeyPath: ExpressionKeys.body.rawValue)
        let bodySearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: bodyExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        
        searchMailsPredicate.append(bodySearchComparisonPredicate)
        
        
        let orMatchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchMailsPredicate)
        
        return orMatchPredicate
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = emails
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        // Build all the "AND" expressions for each value in searchString.
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate =
            NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? MailResultTableViewController {
            resultsController.filteredMail = filteredResults
            resultsController.tableView.reloadData()
        }
    }
    
}

extension MailContentTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let email = emails[indexPath.row]
        
        if orientation == .left {
            guard swipeRightEnabled else { return nil }
            
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
                let toggleUnreadState = !email.unread
                email.unread = toggleUnreadState
                
                let cell = tableView.cellForRow(at: indexPath) as! MailCell
                cell.setUnread(toggleUnreadState, animated: true)
            }
            
            read.hidesWhenSelected = true
            read.accessibilityLabel = email.unread ? "Mark as Read" : "Mark as Unread"
            
            let descriptor: SwipeActionDescriptor = email.unread ? .read : .unread
            configure(action: read, with: descriptor)
            
            return [read]
        } else {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                self.emails.remove(at: indexPath.row)
            }
            configure(action: delete, with: .trash)
            
            let cell = tableView.cellForRow(at: indexPath) as! MailCell
            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
                self.present(controller, animated: true, completion: nil)
            }
            configure(action: more, with: .more)
            
            return [delete, flag, more]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultSwipeOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: SwipeActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}

// MARK: - MailCell
class MailCell: SwipeTableViewCell {
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var subjectLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    
    var animator: Any?
    
    var indicatorView = IndicatorView(frame: .zero)
    
    var unread = false {
        didSet {
            indicatorView.transform = unread ? CGAffineTransform.identity : CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        }
    }
    
    override func awakeFromNib() {
        setupIndicatorView()
    }
    
    func setupIndicatorView() {
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = tintColor
        indicatorView.backgroundColor = .clear
        contentView.addSubview(indicatorView)
        
        let size: CGFloat = 12
        indicatorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor).isActive = true
        indicatorView.centerXAnchor.constraint(equalTo: fromLabel.leftAnchor, constant: -16).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor).isActive = true
    }
    
    func setUnread(_ unread: Bool, animated: Bool) {
        let closure = {
            self.unread = unread
        }
        
        if #available(iOS 10, *), animated {
            var localAnimator = self.animator as? UIViewPropertyAnimator
            localAnimator?.stopAnimation(true)
            
            localAnimator = unread ? UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.1) : UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1.0)
            localAnimator?.addAnimations(closure)
            localAnimator?.startAnimation()
            
            self.animator = localAnimator
        } else {
            closure()
        }
    }
}
