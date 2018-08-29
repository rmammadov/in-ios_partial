//
//  UIApplication+getPresentedViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func getPresentedViewController() -> UIViewController? {
        var presentViewController = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentViewController?.presentedViewController
        {
            presentViewController = pVC
        }
        
        return presentViewController
    }
}
