//
//  ComposeViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-05.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController

class ComposeViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var ToTextView: UITextField!
    @IBOutlet weak var SubjectTextView: UITextField!
    @IBOutlet weak var UrgentSwitch: UISwitch!
    @IBOutlet weak var BodyTextView: UITextView!
    var ApiUrl = eHealth(url: "http://otu-capstone.cs.uregina.ca:3000")
    
    let navBar = SPFakeBarView.init(style: .stork)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var selectedContact: contact? = nil
    var composeDraft: Draft? = nil
    var reply_sender_id: Int? = nil
    var reply_message_id: String? = nil
    var noSubjectTitle = "Empty Subject"
    var noSubjectMessage = "This message has no subject. You need a subject to send mail"
    var noSenderTitle = "Empty Sender"
    var noSenderMessage = "This message has no sender. You need a sender to send mail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.navBar.titleLabel.text = "New Message"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitle("Send", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        self.navBar.rightButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)

        self.view.addSubview(self.navBar)
        
        if let con = selectedContact {
            self.ToTextView.text = con.first_name + " " + con.last_name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.reply_message_id != nil && self.reply_sender_id != nil) {
            ToTextView.text = String(reply_sender_id!)
        }
    }
    
    @IBAction func SubjectTextViewChanged(_ sender: UITextField) {
        self.navBar.titleLabel.text = sender.text
    }
    
    @IBAction func addContact(_ sender: UIButton) {
        self.segueToContactViewController()
    }
    
    @objc func send() {
        guard let to = ToTextView.text, let subject = SubjectTextView.text, let body = BodyTextView.text, case let urgent = UrgentSwitch.isOn else { return }
        let recpt_ids: [String] = [to]
        
        if (subject == "") {
            self.makeAlertController(title: noSubjectTitle, message: noSubjectMessage)
        } else if (to == "") {
            self.makeAlertController(title: noSenderTitle, message: noSenderMessage)
        } else {
            if (self.reply_message_id != nil && self.reply_sender_id != nil) {
                let ids: [String] = [String(self.reply_sender_id!)]
                self.compose(recpt_ids: ids, body: body, subject: subject, reply_to_id: self.reply_message_id!, urgent: urgent)
            } else {
                self.compose(recpt_ids: recpt_ids, body: body, subject: subject, reply_to_id: "", urgent: urgent)
            }
        }
    }
    
    func makeAlertController(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
    func compose(recpt_ids: [String], body: String, subject: String, reply_to_id: String, urgent: Bool) {
        if (self.ApiUrl.Auth(User: LoginViewController.username, Password: LoginViewController.password) == true) {
            if let result = self.ApiUrl.ComposeMessage(recpt_ids: recpt_ids, body: body, subject: subject, reply_to_id: "", urgent: urgent) {
//                print("\(result)")
                self.dismiss()
            }
        }
    }
    
    @objc func cancel() {
        self.dismiss()
    }
    
    public func segueToContactViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "contactsViewController") as? ContactsViewController
        
        let modal = controller
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = 500
        modal?.transitioningDelegate = transitionDelegate
        modal?.modalPresentationStyle = .custom
        self.present(modal!, animated: true, completion: nil)
    }
    
}


struct Draft {
    let recpt_ids: [String]
    let body: String
    let subject: String
    let reply_to_id: String
    let urgent: Bool
    
    init(recpt_ids: [String], body: String, subject: String, reply_to_id: String, urgent: Bool) {
        self.recpt_ids = recpt_ids
        self.body = body
        self.subject = subject
        self.reply_to_id = reply_to_id
        self.urgent = urgent
    }
};
