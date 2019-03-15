
//
//  ContactListTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-12.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    var eMail = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var contacts: [contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initializeCells()
    }

    func initializeCells() {
        if (eMail.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true ) {
            if let profileResult = eMail.GetMatchings() {
                for con in profileResult.included {
                    print(con)
                    let temp = contact(first_name: con.attributes.first_name, last_name: con.attributes.last_name, id: con.id, type: con.type)
                    contacts.append(temp)
                }
            }
        }
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: true)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsIdentifier", for: indexPath)
        let name = contacts[indexPath.row].first_name + " " + contacts[indexPath.row].last_name
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = String(contacts[indexPath.row].id)
        cell.imageView?.setImage(string: name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: true)
//        let imageView = cell.imageView
//        getCustomImage(imageDisplayName: contacts[indexPath.row].first_name + " " + contacts[indexPath.row].last_name, imageView: imageView)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//class contact: NSObject {
//    var first_name : String
//    var last_name : String
//    var id : Int
//    var type : String
//
//    init(first_name: String, last_name: String, id: Int, type: String) {
//        self.first_name = first_name
//        self.last_name = last_name
//        self.id = id
//        self.type = type
//    }
//}
