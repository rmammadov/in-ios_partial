//
//  NavigationHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/24/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class NavigationHelper {
    
    static func getCurrentVC() -> UIViewController {
        guard let topController = UIApplication.shared.keyWindow?.rootViewController else {return}
        
        return topController
    }
}
