//
//  ApiManager.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class ApiManager {
    
    let requestHandler = ApiRequestHandler()
    
    func getMenuItems() {
        self.requestHandler.requestMenuItems()
    }
}
