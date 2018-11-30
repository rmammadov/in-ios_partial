//
//  BaseModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class BaseModel {
    
    func isInternetAvailable() -> Bool {
        return ReachabilityManager.shared.isNetworkAvailable
    }
    
    func setLastState(idOfView: String) {
        SettingsHelper.shared.setLastState(idOfView: idOfView)
    }
}
