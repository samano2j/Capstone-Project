//
//  CancelButton.swift
//  Capstone
//
//  Created by Christian John on 2019-02-07.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit

let kCancelButtonBackgroundColor = UIColor(displayP3Red: 222/255, green: 222/255, blue: 222/255, alpha: 1)
let kCancelButtonTintColor = UIColor.white
let kCancelButtonCornerRadius: CGFloat = 20.0

class CancelButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    private func configureUI() {
        self.backgroundColor = kCancelButtonBackgroundColor
//        self.layer.cornerRadius = kCancelButtonCornerRadius
        self.viewWithTag(5)!.addCornerRadiusAnimation(to: kLoginButtonCornerRadius, duration: 1.3)
        self.viewWithTag(5)!.setDeepShadow()
        self.tintColor = kCancelButtonTintColor
        self.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
    }
}
