//
//  MailResultTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2018-11-21.
//  Copyright © 2018 Christian John. All rights reserved.
//

import UIKit
class MailResultTableViewController: MailContentTableViewController {
    
    var filteredMail: [Email] = []
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMail.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell") as! MailCell
        cell.delegate = self
        cell.backgroundView = createSelectedBackgroundView()
        
        let email = filteredMail[indexPath.row]
        cell.fromLabel.text = email.from
        cell.dateLabel.text = email.relativeDateString
        cell.subjectLabel.text = email.subject
        cell.bodyLabel.text = email.body
        cell.unread = email.unread
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let email = filteredMail[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? MailCell {
            let toggleUnreadState = !email.unread
            email.unread = toggleUnreadState
            
            cell.setUnread(toggleUnreadState, animated: true)
        }
    }

}

