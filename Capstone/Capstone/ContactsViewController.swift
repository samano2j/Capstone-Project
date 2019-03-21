//
//  ContactsViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-12.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let navBar = SPFakeBarView.init(style: .stork)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var eMail = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var contacts: [contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.navBar.titleLabel.text = "Contacts"
        self.navBar.rightButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        
        self.view.addSubview(self.navBar)
        self.tableView.tableFooterView = UIView()
        
        tableView.contentInset.top = self.navBar.height
        tableView.scrollIndicatorInsets.top = self.navBar.height
        
        initializeCells()
    }
    
    @objc func cancel() {
        self.dismiss()
    }
    
    func initializeCells() {
        if (eMail.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true ) {
            if let profileResult = eMail.GetMatchings() {
                print(profileResult)
                for con in profileResult.included {
                    let temp = contact(first_name: con.attributes.first_name, last_name: con.attributes.last_name, id: con.id, type: con.type)
                    contacts.append(temp)
                }
            }
        }
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!) {
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: true)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: true)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsListIdentifier", for: indexPath) as! ContactTableViewCell
        let name = contacts[indexPath.row].first_name + " " + contacts[indexPath.row].last_name
        cell.nameLabel?.text = name
        cell.contactImage?.setImage(string: name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: false)
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("SELECTED INDEX \(indexPath.row)")
////        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////        let newViewController = storyBoard.instantiateViewController(withIdentifier: "composeViewController") as! ComposeViewController
////
////        newViewController.selectedContact = contacts[indexPath.row]
////        self.dismiss()
//        tableView.deselectRow(at: indexPath, animated: true)
//        //self.present(newViewController, animated: false, completion: nil)
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
}

extension ContactsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        SPStorkController.scrollViewDidScroll(scrollView)
    }
}

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class contact: NSObject {
    var first_name : String
    var last_name : String
    var id : Int
    var type : String
    
    override init() {
        self.first_name = ""
        self.last_name = ""
        self.id = 0
        self.type = ""
    }
    
    init(first_name: String, last_name: String, id: Int, type: String) {
        self.first_name = first_name
        self.last_name = last_name
        self.id = id
        self.type = type
    }
}
