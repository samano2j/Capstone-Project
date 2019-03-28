//
//  MailTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2018-11-19.
//  Copyright © 2018 Christian John. All rights reserved.
//

import UIKit

class MailTableViewController: UITableViewController {
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBAction func compose(_ sender: UIBarButtonItem) {
        self.segueToComposeViewController()
    }
    
    let email = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var results : Folder.result? = nil
    static var mailFolders = [Folders]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let edit = self.editButtonItem
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createFolder))
        self.navigationItem.rightBarButtonItems = [edit, add]
        
        tableView.allowsSelection = true
        definesPresentationContext = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        initializeTableViewDataSource()
    }
    
    func initializeTableViewDataSource() {
        if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true ) {
            results = email.GetFolders()
            if (results != nil) {
                for mail in (results?.data)! {
                    let mailBoxCount = (mail.attributes.message_count == 0) ? "" : String(mail.attributes.message_count)
                    let folder = Folders(folderName: mail.attributes.name, folderMessagesCount: mailBoxCount, folderID: mail.id)
                    MailTableViewController.mailFolders.append(folder)
                }
            }
        }
    }
    
    func error() {
        let err = UIAlertController(title: "Error", message: "⚠️Sorry this action cannot be executed", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        err.addAction(ok)
        
        present(err, animated: true)
    }
    
    @objc func createFolder() {
        let ac = UIAlertController(title: "Create Folder", message: "Enter Folder Name", preferredStyle: .alert)
        ac.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Create", style: .default) { [unowned ac] _ in
            guard let answer = ac.textFields![0].text else { return }
            if (self.email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true ) {
                if self.email.CreateFolder(folder_name: answer, parent_folder_id: nil) == nil {
                    self.error()
                } else {
                    MailTableViewController.mailFolders.removeAll(keepingCapacity: true)
                    self.initializeTableViewDataSource()
                    self.tableView.reloadData()
                }
            }
        }
        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MailTableViewController.mailFolders.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailBoxesCell", for: indexPath)
        cell.textLabel?.text = MailTableViewController.mailFolders[indexPath.row].folderName
        cell.detailTextLabel?.text = MailTableViewController.mailFolders[indexPath.row].folderMessagesCount
        cell.imageView?.image = MailTableViewController.returnImageForFolderType(name: MailTableViewController.mailFolders[indexPath.row].folderName)

//        if (indexPath.row == 3) {
//            cell.separatorInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
//        }
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }*/
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteRows))
        self.toolbarItems = (tableView.isEditing) ? [spacer, delete] : [spacer, composeButton]
    }
    
    @objc func deleteRows() {
        if let selectedRows = self.tableView.indexPathsForSelectedRows {
            // 1 The selected rows are added to a temporary array
            var items = [Folders]()
            for indexPath in selectedRows {
                items.append(MailTableViewController.mailFolders[indexPath.row])
            }
            // 2 The index of the items of the temporary array will be used to remove the items of the MailBoxes array and
            for item in items {
                if let index = MailTableViewController.mailFolders.index(where: { $0.folderName == item.folderName }) {
                    if (email.DeleteFolder(folder_id: MailTableViewController.mailFolders[index].folderID)) {
                        MailTableViewController.mailFolders.remove(at: index)
                    }
                }
            }
            // 3
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .left)
            tableView.endUpdates()
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
                if (email.DeleteFolder(folder_id: MailTableViewController.mailFolders[indexPath.row].folderID)) {
                    MailTableViewController.mailFolders.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "MailBoxesCellSegue":
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? MailContentTableViewController {
                    seguedToMVC.titleStringViaSegue = MailTableViewController.mailFolders[indexPath.row].folderName
                    seguedToMVC.folderID = MailTableViewController.mailFolders[indexPath.row].folderID
                }
            default: break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MailTableViewController.mailFolders.removeAll(keepingCapacity: true)
        self.initializeTableViewDataSource()
        self.tableView.reloadData()
    }
    
    static public func returnImageForFolderType(name: String) -> UIImage {
        var image: UIImage
        switch name {
        case "Inbox":
            image = #imageLiteral(resourceName: "Inbox")
        case "Drafts":
            image = #imageLiteral(resourceName: "Drafts")
        case "Sent":
            image = #imageLiteral(resourceName: "Sent")
        case "Junk":
            image = #imageLiteral(resourceName: "Archive-1")
        case "Trash":
            image = #imageLiteral(resourceName: "Trash-1")
        case "Archive":
            image = #imageLiteral(resourceName: "Archive-1")
        default:
            image = #imageLiteral(resourceName: "Folder")
        }
        return image
    }
}

struct Folders {
    let folderName: String
    let folderID: String
    let folderMessagesCount: String
    
    init(folderName name: String, folderMessagesCount count: String, folderID id: String) {
        self.folderName = name
        self.folderMessagesCount = count
        self.folderID = id
    }
};
