//
//  UrgentLabel.swift
//  Capstone
//
//  Created by Christian John on 2019-03-08.
//  Copyright © 2019 Christian John. All rights reserved.
//
import UIKit

class UrgentLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    private func configureUI() {
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.5
        self.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
}
