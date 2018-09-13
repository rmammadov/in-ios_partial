//
//  INTextField.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class INTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
