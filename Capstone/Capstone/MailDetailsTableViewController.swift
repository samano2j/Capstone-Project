//
//  MailDetailsTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-31.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class MailDetailsTableViewController: UITableViewController {
    
    var emailService: [Email] = []
    var details = Details(from: "", to: "", subject: "", date: "", body: "", index: 6, emails: [])
    var indexPath: Int = 4
    // Outlets
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func compose(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
        
        let modal = controller
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal?.transitioningDelegate = transitionDelegate
        modal?.modalPresentationStyle = .custom
        self.present(modal!, animated: true, completion: nil)
    }
    
    @IBAction func pressedUp(_ sender: UIBarButtonItem) {
        emailService = details.emails
        indexPath = indexPath - 1
        if (indexPath >= 0 && indexPath < emailService.count) {
            configureView(from: emailService[indexPath].from, to: emailService[indexPath].to, subject: emailService[indexPath].subject, date: "\(emailService[indexPath].date)", body: emailService[indexPath].body, index: indexPath)
            getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
        }
    }
    
    @IBAction func pressedDown(_ sender: UIBarButtonItem) {
        emailService = details.emails
        indexPath = indexPath + 1
        if (indexPath >= 0 && indexPath < emailService.count) {
            configureView(from: emailService[indexPath].from, to: emailService[indexPath].to, subject: emailService[indexPath].subject, date: "\(emailService[indexPath].date)", body: emailService[indexPath].body, index: indexPath)
            getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(from: details.from, to: details.to, subject: details.subject, date: details.date, body: details.body, index: details.index)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        getCustomImage(imageDisplayName: fromLabel.text, imageView: imageView)
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
        var height: CGFloat = 0
        if (indexPath.section == 0 && indexPath.row == 2) {
            let maxLabelSize = CGSize(width: bodyLabel.frame.width, height: .greatestFiniteMagnitude)
            let actualLabelSize = bodyLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: bodyLabel.font], context: nil).height
        
            let labelHeight = actualLabelSize
            height = labelHeight + 50
            bodyCell.separatorInset = UIEdgeInsets(top: 0, left: bodyCell.bounds.size.width, bottom: 0, right: 0)
        }
        else if (indexPath.section == 0 && indexPath.row == 1) {
            let maxLabelSize = CGSize(width: subjectLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let actualLabelSize = subjectLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: subjectLabel.font], context: nil).height
            let dateActualLabelSize = dateLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: dateLabel.font], context: nil).height
            let labelHeight = actualLabelSize
            height = labelHeight + dateActualLabelSize + 20
        }
        else {
            height = 67.0
        }
        return height
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
