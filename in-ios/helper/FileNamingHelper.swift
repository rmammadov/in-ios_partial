//
//  FileNamingHelper.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/11/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class FileNamingHelper {
    
    func getNewFileName() -> String {
        
        return UIDevice.current.identifierForVendor!.uuidString + "_" + String(Date().timeIntervalSince1970)
    }
}
