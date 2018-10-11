//
//  InputValidationHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/8/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class InputValidationHelper {
    
    let shared = InputValidationHelper()
    
    func isValidInput(Input:String, regEx: String) -> Bool {
        let RegEx = regEx
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }
}
