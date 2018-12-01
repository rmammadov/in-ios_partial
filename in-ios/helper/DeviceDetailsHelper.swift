//
//  DeviceDetailsHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 12/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import UIKit

class DeviceDetailsHelper {
    
    func getDeviceType() -> String {
        return UIDevice.current.model
    }
    
    func getDeviceModel() -> String {
        return UIDevice.current.modelName
    }
    
    func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    func getScreenResolution() -> String {
        let screenSize: CGRect = UIScreen.main.bounds
        return "Width: \(screenSize.width) x Height: \(screenSize.height)"
    }
}
