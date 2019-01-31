//
//  MailTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2018-11-19.
//  Copyright © 2018 Christian John. All rights reserved.
//

import UIKit

class MailTableViewController: UITableViewController {
    
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
    var Messages : Message.result? = nil
    let email = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var results : Folder.result? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.allowsSelection = true
        definesPresentationContext = true
        
        if (email.Auth(User: "max", Password: "1234") == true )
        {
            results = email.GetFolders()
            if (results != nil)
            {
                for mail in (results?.data)! {
                    MailBoxes.append(mail.attributes.name)
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
        switch cell.textLabel?.text {
        case "Inbox":
            if let image = UIImage.init(named: "Inbox") {
                cell.imageView?.image = image
            }
        case "Drafts":
            if let image = UIImage.init(named: "Drafts") {
                cell.imageView?.image = image
            }
        case "Sent":
            if let image = UIImage.init(named: "Sent") {
                cell.imageView?.image = image
            }
        case "Junk":
            if let image = UIImage.init(named: "Folder") {
                cell.imageView?.image = image
            }
        case "Trash":
            if let image = UIImage.init(named: "Trash-1") {
                cell.imageView?.image = image
            }
        case "Archive":
            if let image = UIImage.init(named: "Archive-1") {
                cell.imageView?.image = image
            }
        default:
            if let image = UIImage.init(named: "Folder") {
                cell.imageView?.image = image
            }
        }

        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }*/
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            MailBoxes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "MailBoxesCellSegue":
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? MailContentTableViewController {
                    seguedToMVC.titleStringViaSegue = MailBoxes[indexPath.row]
                    if (email.Auth(User: "max", Password: "1234") == true )
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
    
}
