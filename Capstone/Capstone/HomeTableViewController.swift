//
//  HomeTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-26.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SafariServices
import PusherChatkit

class HomeTableViewController: UITableViewController {
    var folders: [Folders]!
    let email = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mockServices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "services", for: indexPath) as! ServiceCell
        cell.serviceImage.image = mockServices[indexPath.row].serviceImage
        cell.serviceTitle.text = mockServices[indexPath.row].serviceTitle
        cell.serviceBody.text = mockServices[indexPath.row].serviceBody
        cell.serviceLink.text = mockServices[indexPath.row].serviceLink
        cell.serviceLinkImage.image = mockServices[indexPath.row].serviceLinkImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let url = URL(string: "https://www.onlinetherapyuser.ca/wellbeing-program") else { return }
            openURL(url)
        } else if indexPath.row == 1 {
            guard let url = URL(string: "https://www.onlinetherapyuser.ca/pain") else { return }
            openURL(url)
        } else if indexPath.row == 2 {
            guard let url = URL(string: "https://www.onlinetherapyuser.ca/chronic-conditions") else { return }
            openURL(url)
        } else if indexPath.row == 3 {
            guard let url = URL(string: "https://www.onlinetherapyuser.ca/sci") else { return }
            openURL(url)
        }
    }
    
    func openURL(_ url: URL) {
        let webViewController = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            webViewController.preferredControlTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            webViewController.preferredBarTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            webViewController.configuration.accessibilityNavigationStyle = .combined
        }
        present(webViewController, animated: true, completion: nil)
    }
    
    func fetchFolders() {
        if (email.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true ) {
            let results = email.GetFolders()
            if (results != nil) {
                for mail in (results?.data)! {
                    let mailBoxCount = (mail.attributes.message_count == 0) ? "" : String(mail.attributes.message_count)
                    let folder = Folders(folderName: mail.attributes.name, folderMessagesCount: mailBoxCount, folderID: mail.id)
                    MailTableViewController.mailFolders.append(folder)
                }
            }
        }
    }
}


class Services: NSObject {
    let serviceImage: UIImage
    let serviceTitle: String
    let serviceBody: String
    let serviceLink: String
    let serviceLinkImage: UIImage
    
    init(serviceImage: UIImage, serviceTitle: String, serviceBody: String, serviceLink: String, serviceLinkImage: UIImage) {
        self.serviceImage = serviceImage
        self.serviceTitle = serviceTitle
        self.serviceBody = serviceBody
        self.serviceLink = serviceLink
        self.serviceLinkImage = serviceLinkImage
    }
}

class ServiceCell: UITableViewCell {
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var serviceBody: UILabel!
    @IBOutlet weak var serviceLink: UILabel!
    @IBOutlet weak var serviceLinkImage: UIImageView!
}

let mockServices: [Services] = [Services(serviceImage: #imageLiteral(resourceName: "Screen Shot 2019-02-26 at 1.10.01 AM"), serviceTitle: "The WellBeing Course", serviceBody: "An online course that helps people with thoughts, behaviours and physical symptons of depression and anxiety. This is a Therapist-assisted course offered to Saskatchewan residents.", serviceLink: "Learn More", serviceLinkImage: #imageLiteral(resourceName: "right")), Services(serviceImage: #imageLiteral(resourceName: "Screen Shot 2019-02-26 at 1.52.55 AM"), serviceTitle: "The Pain Course", serviceBody: "An online course that teaches people who have chronic pain how to better manage pain, depression, and anxiety. This is a guided course offered to Saskatchewan residents. ", serviceLink: "Learn More", serviceLinkImage: #imageLiteral(resourceName: "right")), Services(serviceImage: #imageLiteral(resourceName: "Screen Shot 2019-02-26 at 1.53.27 AM"), serviceTitle: "The Chronic Conditions Course", serviceBody: "An online course that teaches people who have a chronic condition, how to manage depression and anxiety. This is a guided course offered to Canadian residents. ", serviceLink: "Learn More", serviceLinkImage: #imageLiteral(resourceName: "right")), Services(serviceImage: #imageLiteral(resourceName: "Screen Shot 2019-02-26 at 1.53.47 AM"), serviceTitle: "The Wellbeing for Spinal Cord injury Course", serviceBody: "An online course that teaches people with spinal cord injury (SCI) skills to help them better manage their emotional well being. This is a guided course offered to Canadian residents. ", serviceLink: "Learn More", serviceLinkImage: #imageLiteral(resourceName: "right"))]
