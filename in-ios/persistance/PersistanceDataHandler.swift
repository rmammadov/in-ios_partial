//
//  PersistanceDataHandler.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/23/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class PersistanceDataHandler {
    
    static func saveCoreDataChanges() {
        PersistanceService.shared.saveContext()
    }
}
