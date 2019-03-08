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
    
    func callback(data: String, error: String?) {
        
        if (error == nil) {
            print(data)
        }
        else
        {
            print("Error -> \(String(describing: error))")
        }
    }
    
    var MailBoxes = [String]()
    var MailBoxesCount: [String:String] = [:]
    var Messages : Message.result? = nil
    let email = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var results : Folder.result? = nil
    var mailFolderID: [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.allowsSelection = true
        definesPresentationContext = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true )
        {
            results = email.GetFolders()
            if (results != nil)
            {
                for mail in (results?.data)! {
                    MailBoxes.append(mail.attributes.name)
                    let mailBoxCount = (mail.attributes.message_count == 0) ? "" : String(mail.attributes.message_count)
                    MailBoxesCount.updateValue(mailBoxCount, forKey: mail.attributes.name)
                    mailFolderID.updateValue(mail.id, forKey: mail.attributes.name)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MailBoxes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailBoxesCell", for: indexPath)
        cell.textLabel?.text = MailBoxes[indexPath.row]
        cell.detailTextLabel?.text = MailBoxesCount[MailBoxes[indexPath.row]]
        let temp = cell.textLabel?.text
        cell.imageView?.image = MailTableViewController.returnImageForFolderType(name: temp!)

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
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(addTapped))
        if (tableView.isEditing) {
            self.toolbarItems = [spacer, delete]
        } else {
            self.toolbarItems = [spacer, composeButton]
        }
    }
    
    @objc func addTapped() {
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
                if (email.DeleteFolder(folder_id: mailFolderID[MailBoxes[indexPath.row]]!)) {
                    MailBoxes.remove(at: indexPath.row)
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
                    seguedToMVC.titleStringViaSegue = MailBoxes[indexPath.row]
                    if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true )
                    {
                        results = email.GetFolders()
                        for mail in (results?.data)! {
                            if MailBoxes[indexPath.row] == mail.attributes.name {
                                seguedToMVC.folderID = mail.id
                            }
                        }
                    }
                }
            default: break
            }
        }
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
