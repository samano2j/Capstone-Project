//
//  ComposeViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-05.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var toLabel: UILabel!
    let navBar = SPFakeBarView(style: .stork)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.white
        self.modalPresentationCapturesStatusBarAppearance = true
        
//        let darkendBarTintColor = #colorLiteral(red: 0.08335601538, green: 0.09890990704, blue: 0.367097348, alpha: 1)
        
//        self.navBar.backgroundColor = darkendBarTintColor
        
        self.navBar.titleLabel.text = "New Message"
        self.navBar.leftButton.setTitle("Cancel", for: .normal)
        self.navBar.rightButton.setTitle("Send", for: .normal)
        self.navBar.rightButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.navBar.leftButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.view.addSubview(self.navBar)
    }
    
    @objc func dismissAction() {
        self.dismiss()
    }
}
