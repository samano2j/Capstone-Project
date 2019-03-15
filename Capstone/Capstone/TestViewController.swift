//
//  TestViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-11.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController

class TestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let tableViewModels: models = models(to: "Max Zaine", subject: "Just working on something new", urgent: true, body: "Hopefully this works because I don't know whatelse to do and time is running out")
    
    let navBar = SPFakeBarView.init(style: .small)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.navBar.titleLabel.text = "New Message"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitle("Send", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        self.navBar.rightButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        
        self.view.addSubview(self.navBar)
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    @objc func cancel() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell: UITableViewCell
        if (indexPath.row == 0) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "toIdentifier", for: indexPath as IndexPath) as! ToTableViewCell
            cell.toTextField.text = self.tableViewModels.to
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectIdentifier") as! SubjectTableViewCell
            cell.subjectTextField.text = self.tableViewModels.subject
            return cell
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "urgentIdentifier") as! UrgentTableViewCell
            cell.urgent.text = "Urgent: "
            cell.urgentSwitch.isOn = self.tableViewModels.urgent
            cell.addCornerRadiusAnimation(to: 10.0, duration: 5.0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bodyIdentifier") as! BodyTableViewCell
            cell.bodyLabel.text = self.tableViewModels.body
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectIdentifier") as! SubjectTableViewCell
            return (cell.subjectTextField.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))!
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bodyIdentifier") as! BodyTableViewCell
            return (cell.bodyLabel.text?.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 15)))!
        } else {
            return 44
        }
    }
//    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 4
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MailBoxesCell", for: indexPath)
//        cell.textLabel?.text = MailBoxes[indexPath.row]
//        cell.detailTextLabel?.text = MailBoxesCount[MailBoxes[indexPath.row]]
//        let temp = cell.textLabel?.text
//        cell.imageView?.image = MailTableViewController.returnImageForFolderType(name: temp!)
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell: UITableViewCell? = nil
//        if (indexPath.row == 0) {
//            cell = self.tableView.dequeueReusableCell(withIdentifier: "toIndentifier", for: indexPath as IndexPath) as! ToTableViewCell
//            cell.
//        } else if (indexPath.row == 1) {
//            cell = tableView.dequeueReusableCell(withIdentifier: "subjectIndentifier", for: indexPath) as! SubjectTableViewCell
//        } else if (indexPath.row == 2) {
//            cell = tableView.dequeueReusableCell(withIdentifier: "urgentIndentifier", for: indexPath) as! UrgentTableViewCell
//        } else {
//            cell = tableView.dequeueReusableCell(withIdentifier: "bodyIndentifier", for: indexPath) as! BodyTableViewCell
//        }
//
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class ToTableViewCell: UITableViewCell {
    @IBOutlet weak var addContact: UIButton!
    @IBOutlet weak var toTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

class SubjectTableViewCell: UITableViewCell {
    @IBOutlet weak var subjectTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

class UrgentTableViewCell: UITableViewCell {
    @IBOutlet weak var urgent: UILabel!
    @IBOutlet weak var urgentSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class BodyTableViewCell: UITableViewCell {
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class models: NSObject {
    let to: String
    let subject: String
    let urgent: Bool
    let body: String
    
    init(to: String, subject: String, urgent: Bool, body: String) {
        self.to = to
        self.subject = subject
        self.urgent = urgent
        self.body = body
    }
}
