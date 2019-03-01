//
//  ComposeViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-05.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var ToTextView: UITextField!
    @IBOutlet weak var CcTextView: UITextField!
    @IBOutlet weak var SubjectTextView: UITextField!
    
    let navBar = SPFakeBarView(style: .stork)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        
//        let darkendBarTintColor = #colorLiteral(red: 0.08335601538, green: 0.09890990704, blue: 0.367097348, alpha: 1)
//        self.navBar.backgroundColor = darkendBarTintColor
        
        self.navBar.titleLabel.text = "New Message"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitle("Send", for: .normal)
//        let horizontalSpacing1 = NSLayoutConstraint(item: self.navBar.leftButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.navBar.titleLabel, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 10)
//        let horizontalSpacing2 = NSLayoutConstraint(item: self.navBar.titleLabel, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.navBar.rightButton, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 10)
//        NSLayoutConstraint.activate([horizontalSpacing1, horizontalSpacing2])

        self.navBar.rightButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.navBar.leftButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.view.addSubview(self.navBar)
    }
    
    @IBAction func SubjectTextViewChanged(_ sender: UITextField) {
        self.navBar.titleLabel.text = sender.text
    }
    
    @objc func dismissAction() {
        self.dismiss()
    }
}
