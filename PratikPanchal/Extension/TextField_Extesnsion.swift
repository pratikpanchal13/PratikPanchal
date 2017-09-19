//
//  TextField_Extesnsion.swift
//  PratikPanchal
//
//  Created by Pratik on 19/09/17.
//  Copyright © 2017 Pratik. All rights reserved.
//

import UIKit
import Foundation


//MARK:- TextField Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
