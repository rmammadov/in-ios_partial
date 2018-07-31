//
//  ApiManager.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

class ApiManager {
    
    fileprivate let requestHandler = ApiRequestHandler()
    
    fileprivate var menuItems: Array<MenuItem>?
    
    func getMenuItems() {
        self.requestHandler.requestMenuItems()
    }
}
