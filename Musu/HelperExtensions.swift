//
//  HelperExtensions.swift
//  Musu
//
//  Created by Richard Zarth on 5/31/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

// http://purelywebdesign.co.uk/tutorial/swift-underlined-text-field-tutorial/
extension UITextField {
    func underlined() {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
