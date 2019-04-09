//
//  MailDetailsTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-31.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController

class MailDetailsTableViewController: UITableViewController {
    
    var emailService: [Email] = []
    var details = Details(from: "", to: "", subject: "", date: "", body: "", index: 6, emails: [])
    var singleMessage: Message.SingleMessage.result?
    var indexPath: Int = 4
    var ApiUrl = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    var folderID = ""
    var folder: Folders!
    var DetMailBoxes = [String: String]()
    var results : Folder.result? = nil
    // Outlets
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func compose(_ sender: UIBarButtonItem) {
        self.segueToComposeViewController()
    }
    
    @IBAction func moveMessages(_ sender: UIBarButtonItem) {
        if (self.ApiUrl.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
            results = self.ApiUrl.GetFolders()
            let controller = UIAlertController(title: nil, message: "Move this message to a new mailbox.", preferredStyle: .actionSheet)
            
            if (results != nil) {
                for mail in (results?.data)! {
                    DetMailBoxes.updateValue(mail.id, forKey: mail.attributes.name)
                }
                for temp in DetMailBoxes {
                    let action = UIAlertAction(title: temp.key, style: .default, handler: {(_) in let _ = self.ApiUrl.MoveMessages(from_folder: self.folder.folderID, to_folder: temp.value, message_ids: [self.emailService[self.indexPath].id])
                        if (self.indexPath >= 0 && self.indexPath < self.emailService.count - 1) {
                            self.indexPath = self.indexPath + 1
                            self.moveToNextMailDetails()
                        }
                    })
                    action.setValue(MailTableViewController.returnImageForFolderType(name: temp.key), forKey: "image")
                    controller.addAction(action)
                }
                
                let destroyAction = UIAlertAction(title: "Cancel", style: .cancel) 
                controller.addAction(destroyAction)

                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressedDelete(_ sender: UIBarButtonItem) {
        if (self.ApiUrl.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
            if (self.ApiUrl.DeleteMessage(folder_id: folder.folderID, message_id: emailService[indexPath].id)) {
                indexPath = indexPath + 1
                moveToNextMailDetails()
            }
        }
    }
    
    @IBAction func pressedUp(_ sender: UIBarButtonItem) {
        if (indexPath > 0 && indexPath < emailService.count) {
            indexPath = indexPath - 1
            moveToNextMailDetails()
        }
    }
    
    @IBAction func pressedDown(_ sender: UIBarButtonItem) {
        if (indexPath >= 0 && indexPath < emailService.count - 1) {
            indexPath = indexPath + 1
            moveToNextMailDetails()
        }
    }
    
    func moveToNextMailDetails() {
        if (self.ApiUrl.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
            let singleMessage = self.ApiUrl.GetMessage(folder_id: folder.folderID, message_id: emailService[indexPath].id)
            if (indexPath >= 0 && indexPath < emailService.count) {
                if (folder.folderName == "Sent") {
                    configureView(from: emailService[indexPath].to, to: emailService[indexPath].from, subject: emailService[indexPath].subject, date: emailService[indexPath].date.toString(), body: singleMessage?.data.attributes.body ?? "", index: indexPath)
                } else {
                    configureView(from: emailService[indexPath].from, to: emailService[indexPath].to, subject: emailService[indexPath].subject, date: emailService[indexPath].date.toString(), body: singleMessage?.data.attributes.body ?? "", index: indexPath)
                }
                
                getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
            }
        }
    }
    
    @IBAction func reply(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
        if (self.ApiUrl.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
            if let singleMessage = self.ApiUrl.GetMessage(folder_id: folder.folderID, message_id: emailService[indexPath].id) {
                let senderInfo = self.ApiUrl.GetSenderInformation(Message: singleMessage)
                controller?.reply_sender_id = senderInfo?.id
                controller?.reply_message_id = emailService[indexPath].id
            }
        }
        
        let modal = controller
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal?.transitioningDelegate = transitionDelegate
        modal?.modalPresentationStyle = .custom
        self.present(modal!, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailService = details.emails
        if (folder.folderName == "Sent") {
            configureView(from: details.to, to: details.from, subject: details.subject, date: details.date, body: details.body, index: details.index)
        } else {
            configureView(from: details.from, to: details.to, subject: details.subject, date: details.date, body: details.body, index: details.index)
        }
        
        getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureView(from: String, to: String, subject: String, date: String, body: String, index: Int) {
        fromLabel.text = from
        toLabel.text = to
        subjectLabel.text = subject
        dateLabel.text = date
        bodyLabel.text = body
        indexPath = index
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: UIColor.colorHash(name: name), circular: true, stroke: true)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath.section == 0 && indexPath.row == 2) {
            bodyCell.separatorInset = UIEdgeInsets(top: 0, left: bodyCell.bounds.size.width, bottom: 0, right: 0)
            return (bodyLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))! + 100
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            return (subjectLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))! + (dateLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))! + 20
        } else if (indexPath.section == 0 && indexPath.row == 0){
            return (fromLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))! + (toLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))! + 40
        } else { return 0 }
    }
}


class Details: NSObject {
    let from: String
    let to: String
    let subject: String
    let date: String
    let body: String
    let index: Int
    let emails: [Email]
    
    init(from: String, to: String, subject: String, date: String, body: String, index: Int, emails: [Email]) {
        self.from = from
        self.to = to
        self.subject = subject
        self.date = date
        self.body = body
        self.index = index
        self.emails = emails
    }
}
