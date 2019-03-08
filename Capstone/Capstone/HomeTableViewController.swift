//
//  HomeTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-26.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SafariServices

class HomeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
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
    
    func openURL(_ url: URL) {
        let webViewController = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            webViewController.preferredControlTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            webViewController.preferredBarTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            webViewController.configuration.accessibilityNavigationStyle = .combined
        }
        present(webViewController, animated: true, completion: nil)
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
