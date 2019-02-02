//
//  MailDetailsTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-01-31.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class MailDetailsTableViewController: UITableViewController {
    
    let details = ["chrizj9@gmail.com", "Kayla.Benoit@uregina.ca", "As Featured on CTV Your Morning. Black Friday Deals with 2X Cash Back at 150+ Stores", "\(Calendar.now(addingDays: 0))", "Pairing usually requires an authentication process where a user must validate the connection between devices. The flow of the authentication process varies and usually depends on the interface capabilities of one device or the other. Sometimes pairing is a simple “Just Works” operation, where the click of a button is all it takes to pair (this is common for devices with no UI, like headsets). Other times pairing involves matching 6-digit numeric codes. Older, legacy (v2.0 and earlier), pairing processes involve the entering of a common PIN code on each device. The PIN code can range in length and complexity from four numbers (e.g. “0000” or “1234”) to a 16-character alphanumeric string. Pairing usually requires an authentication process where a user must validate the connection between devices. \nPairing usually requires an authentication process where a user must validate the connection between devices. The flow of the authentication process varies and usually depends on the interface capabilities of one device or the other. Sometimes pairing is a simple “Just Works” operation, where the click of a button is all it takes to pair (this is common for devices with no UI, like headsets). Other times pairing involves matching 6-digit numeric codes. Older, legacy (v2.0 and earlier), pairing processes involve the entering of a common PIN code on each device. The PIN code can range in length and complexity from four numbers (e.g. “0000” or “1234”) to a 16-character alphanumeric string. Pairing usually requires an authentication process where a user must validate the connection between devices. \nPairing usually requires an authentication process where a user must validate the connection between devices. The flow of the authentication process varies and usually depends on the interface capabilities of one device or the other. Sometimes pairing is a simple “Just Works” operation, where the click of a button is all it takes to pair (this is common for devices with no UI, like headsets). Other times pairing involves matching 6-digit numeric codes. Older, legacy (v2.0 and earlier), pairing processes involve the entering of a common PIN code on each device. The PIN code can range in length and complexity from four numbers (e.g. “0000” or “1234”) to a 16-character alphanumeric string. Pairing usually requires an authentication process where a user must validate the connection between devices. \nPairing usually requires an authentication process where a user must validate the connection between devices. The flow of the authentication process varies and usually depends on the interface capabilities of one device or the other. Sometimes pairing is a simple “Just Works” operation, where the click of a button is all it takes to pair (this is common for devices with no UI, like headsets). Other times pairing involves matching 6-digit numeric codes. Older, legacy (v2.0 and earlier), pairing processes involve the entering of a common PIN code on each device. The PIN code can range in length and complexity from four numbers (e.g. “0000” or “1234”) to a 16-character alphanumeric string. Pairing usually requires an authentication process where a user must validate the connection between devices. \nPairing usually requires an authentication process where a user must validate the connection between devices. The flow of the authentication process varies and usually depends on the interface capabilities of one device or the other. Sometimes pairing is a simple “Just Works” operation, where the click of a button is all it takes to pair (this is common for devices with no UI, like headsets). Other times pairing involves matching 6-digit numeric codes. Older, legacy (v2.0 and earlier), pairing processes involve the entering of a common PIN code on each device. The PIN code can range in length and complexity from four numbers (e.g. “0000” or “1234”) to a 16-character alphanumeric string. Pairing usually requires an authentication process where a user must validate the connection between devices. "]
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func configureView() {
        fromLabel.text = details[0]
        toLabel.text = details[1]
        subjectLabel.text = details[2]
        dateLabel.text = details[3]
        bodyLabel.text = details[4]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if (indexPath.section == 0 && indexPath.row == 2) {
            let maxLabelSize = CGSize(width: bodyLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let actualLabelSize = bodyLabel.text!.boundingRect(with: maxLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: bodyLabel.font], context: nil).height
            let labelHeight = actualLabelSize
            height = labelHeight + 20
            if let cell = bodyCell {
                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            }
        }
        else {
            height = 80.0
        }
        return height
    }
}

