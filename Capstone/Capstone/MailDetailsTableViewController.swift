//
//  MailDetailsTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-31.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class MailDetailsTableViewController: UITableViewController {
    
    //var details = []
    var details: [String: String] = ["from":"", "to":"", "subject":"", "date":"", "body":""]
    // Outlets
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var bodyCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureView() {
        fromLabel.text = details["from"]
        toLabel.text = details["to"]
        subjectLabel.text = details["subject"]
        dateLabel.text = details["date"]
        bodyLabel.text = details["body"]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if (indexPath.section == 0 && indexPath.row == 2) {
            let maxLabelSize = CGSize(width: bodyLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
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


