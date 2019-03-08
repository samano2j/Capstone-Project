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
        
        self.navBar.titleLabel.text = "New Message"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitle("Send", for: .normal)
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
    
//    static public func segueToComposeViewController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
//
//        let modal = controller
//        let transitionDelegate = SPStorkTransitioningDelegate()
//        modal?.transitioningDelegate = transitionDelegate
//        modal?.modalPresentationStyle = .custom
//        self.present(modal!, animated: true, completion: nil)
//    }
}


extension UITableViewController {
    public func segueToComposeViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "composeViewController") as? ComposeViewController
        
        let modal = controller
        let transitionDelegate = SPStorkTransitioningDelegate()
        modal?.transitioningDelegate = transitionDelegate
        modal?.modalPresentationStyle = .custom
        self.present(modal!, animated: true, completion: nil)
    }
}
