//
//  MailContentTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2018-11-19.
//  Copyright © 2018 Christian John. All rights reserved.
//

import UIKit
import SwipeCellKit
import SPStorkController

class MailContentTableViewController: UITableViewController {
    // MARK: - Variable Declarations
    var emails: [Email] = []
    var tempEmails: [Email] = []
    var filteredMail: [Email] = []
    var count = 0
    
    var defaultSwipeOptions = SwipeOptions()
    var swipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .circular
    
    var Folder: Folders!
    
    var Messages : Message.result? = nil
    var eMail = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var userInfo: eHealth.profile_information!
    
    // MARK: - Types
    @IBOutlet var composeOutlet: UIBarButtonItem!
    @IBAction func compose(_ sender: UIBarButtonItem) {
        transitionToComposeViewController()
    }
    
    func transitionToComposeViewController() {
        self.segueToComposeViewController()
    }
    
    var unreadClicked: Bool = false {
        didSet {
            ListUnreadMessagesOutlet.tintColor = (unreadClicked) ? #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) : #colorLiteral(red: 0.03448298946, green: 0.426069051, blue: 0.975643456, alpha: 1)
            if (unreadClicked == false) {
                emails.removeAll(keepingCapacity: true)
                emails = tempEmails
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet var ListUnreadMessagesOutlet: UIBarButtonItem!
    @IBAction func ListUnreadMessages(_ sender: UIBarButtonItem) {
        
        if (eMail.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true)
        {
            unreadClicked = !unreadClicked
            if (unreadClicked) {
                Messages = eMail.GetMessages(folder_id: Folder.folderID)
                if (Messages != nil) {
                    let listOfUnreadMessagesTypeUnread = eMail.GetUnreadMessages(Messages: Messages!)
                    var listOfUnreadMessages: [Email] = []
                    for msg in listOfUnreadMessagesTypeUnread {
                        let senderProfile = eMail.GetSenderInformation(messages: Messages!, msg_id: msg.msg_id)
                        let userProfile = eMail.GetProfile()
                        
                        let to = userProfile.first_name ?? "" + " " + userProfile.last_name!
                        let from = senderProfile!.first_name ?? "" + " " + senderProfile!.last_name!
                        
                        let message = Email(from: from, fromID: String((senderProfile?.id)!), to: to, toID: (userProfile.id)!, subject: msg.subject, body: msg.body, date: msg.sent_at.toDate(), unread: true, id: msg.msg_id)
                        listOfUnreadMessages.append(message)
                    }
                    tempEmails = emails
                    emails = listOfUnreadMessages
                    tableView.reloadData()
                }
            }
        }
    }
    
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
//    private var resultsTableController: MailResultTableViewController!
    
    /// Restoration state for UISearchController
    private var restoredState = SearchControllerRestorableState()

    
    // MARK: - viewDIdLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let edit = self.editButtonItem
        self.navigationItem.rightBarButtonItems = [edit]
        ///////////////////////////////////stuffs for search/////////////////////////////////////////////
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Stop the search bar from always being visible
            navigationItem.hidesSearchBarWhenScrolling = true
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.title = Folder.folderName
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
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
        tableView.tableFooterView = UIView()
        
        view.layoutMargins.left = 32
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.resetData()
        }
        
        if (Folder.folderMessagesCount == "") {
            self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            self.tableView.backgroundView = createSelectedBackgroundViewForNoMails()
        }
        
        print("view did load!")
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
        self.tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchController.isActive && !searchBarIsEmpty()) {
            return filteredMail.count
        }
        
        return emails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell") as! MailCell
        cell.delegate = self
        cell.backgroundView = createSelectedBackgroundView()
        
        
        let email: Email
        if (searchController.isActive && !searchBarIsEmpty()) {
            email = filteredMail[indexPath.row]
        }
        else {
            email = emails[indexPath.row]
        }
        
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
            
            if (email.unread == true) {
                email.unread = !email.unread
                cell.setUnread(email.unread, animated: true)
            } else {
                cell.setUnread(false, animated: true)
            }
            
        }
    }
    
    func createSelectedBackgroundViewForNoMails() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        let label = UILabel(frame: CGRect(x: self.tableView.bounds.width / 2 - 42, y: self.tableView.bounds.height / 2, width: 84, height: 30))
        label.textColor = UIColor.darkGray
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 25)
        label.alpha = 0.7
        label.text = "No Mail"
        view.addSubview(label)
        
        return view
    }
    
    // MARK: - Helpers
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func resetData() {
        if (eMail.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true )
        {
            Messages = eMail.GetMessages(folder_id: Folder.folderID)
            if (Messages != nil) {
                for msg in (Messages?.data)! {
                    self.userInfo = eMail.GetProfile()
                    let senderProfile = eMail.GetSenderInformation(messages: Messages!, msg_id: msg.id)
                    
                    let to = userInfo.first_name! + " " + userInfo.last_name!
                    var toId = userInfo.id
                    var from = senderProfile!.first_name! + " " + senderProfile!.last_name!
                    let sent = msg.attributes.sent_at

                    if (Folder.folderName == "Sent") {
                        let toInfo = eMail.GetToInformation(messages: Messages!, msg_id: msg.id)
                        var sendTo = ""
                        for index in toInfo {
                            guard let firstname = index.first_name, let lastname = index.last_name else {return}
                            sendTo += firstname + " " + lastname + ", "
                        }
                        sendTo.removeLast(2)
                        from = sendTo
                        toId = String((toInfo.last?.id)!)
                    }
                    
                    if (Folder.folderName == "Drafts") {
                        let toInfo = eMail.GetToInformation(messages: Messages!, msg_id: msg.id)
                        var sendTo = ""
                        for index in toInfo {
                            guard let firstname = index.first_name, let lastname = index.last_name else {return}
                            sendTo += firstname + " " + lastname + ", "
                        }
                        sendTo.removeLast(2)
                        from = sendTo
                        toId = String((toInfo.last?.id)!)
                    }

                    let sentDate = sent != nil ? sent!.toDate() : Date()
                    DispatchQueue.main.async {
                        let message = Email(from: from, fromID: String((senderProfile?.id)!), to: to, toID: toId!, subject: msg.attributes.subject, body: msg.attributes.body, date: sentDate, unread: (msg.attributes.read_at == nil), id: msg.id)
                        self.emails.append(message)
                        self.tableView.reloadData()
                    }
                }
                count = emails.count
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "detailSegue":
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? MailDetailsTableViewController {
                    let email: Email
                    if (searchController.isActive && !searchBarIsEmpty()) {
                        email = filteredMail[indexPath.row]
                    }
                    else {
                        email = emails[indexPath.row]
                    }
                    
                    let singleMessage = eMail.GetMessage(folder_id: Folder.folderID, message_id: email.id)
                    
                    let det = Details(from: email.from, to: email.to, subject: email.subject, date: email.date.toString(), body: singleMessage?.data.attributes.body ?? "", index: indexPath.row, emails: self.emails)
                    
                    seguedToMVC.details = det
                    seguedToMVC.folder = Folder
                    if let message = singleMessage {
                        seguedToMVC.singleMessage = message
                    }
                    

                    if let _ = MailTableViewController.mailFolders.index(where: { $0.folderID == Folder.folderID && $0.folderName == "Drafts" }) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
                        
                        print("fromID: ", email.fromID, "and toID: ", email.toID)
                        controller?.draft = true
                        controller?.draftTo = email.toID
                        controller?.draftSubject = det.subject
                        controller?.draftBody = det.body
                        controller?.Folder = self.Folder
                        
                        let modal = controller
                        let transitionDelegate = SPStorkTransitioningDelegate()
                        modal?.transitioningDelegate = transitionDelegate
                        modal?.modalPresentationStyle = .custom
                        self.present(modal!, animated: true, completion: nil)
                    }
                    
                }
            default: break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteMultipleMails))
        if (tableView.isEditing) {
            self.toolbarItems = [spacer, delete]
        } else {
            self.toolbarItems = [ListUnreadMessagesOutlet, spacer, composeOutlet]
        }
    }
    
    @objc func deleteMultipleMails() {
        if let selectedRows = self.tableView.indexPathsForSelectedRows {
            // 1 The selected rows are added to a temporary array
            for index in selectedRows {
                print("you have deleted the row: \(index)")
            }
            
            var items = [Email]()
            for indexPath in selectedRows  {
                items.append(emails[indexPath.row])
            }
            // 2 The index of the items of the temporary array will be used to remove the items of the MailBoxes array and
            for item in items {
                if let index = emails.index(of: item) {
                    if (eMail.DeleteMessage(folder_id: Folder.folderID, message_id: item.id)) {
                        emails.remove(at: index)
                    }
                }
            }
            // 3
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .left)
            tableView.endUpdates()
        }
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
        
        filteredMail = filteredResults
        tableView.reloadData()
    }
    
}

extension MailContentTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeAction: [SwipeAction]? = nil
        
        if orientation == .right{
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                if (self.eMail.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
                    if (self.eMail.DeleteMessage(folder_id: self.Folder.folderID, message_id: self.emails[indexPath.row].id)) {
                        self.emails.remove(at: indexPath.row)
                    }
                }
            }
            configure(action: delete, with: .trash)
            
//            let cell = tableView.cellForRow(at: indexPath) as! MailCell
//            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
//            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
//                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
//                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
//                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
//                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
//                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
//                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
//                self.present(controller, animated: true, completion: nil)
//            }
//            configure(action: more, with: .more)
            
            swipeAction = [delete]
        }
        return swipeAction
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
