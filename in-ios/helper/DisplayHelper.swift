//
//  DisplayHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 6/16/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class DisplayHelper {
    
    class func setDisplayDiming(isAlwaysOn: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isAlwaysOn
    }
}
