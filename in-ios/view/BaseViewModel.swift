//
//  BaseViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class BaseViewModel: NSObject {
    
    let modelBase = BaseModel()
    
    func getRowCount() -> Int {
        return Constant.DefaultConfig.COUNT_ROW_ITEMS
    }
    
    func getColumnCount() -> Int {
        return Constant.DefaultConfig.COUNT_COLUMN_ITEMS
    }
    
    func getItemMargin() -> Int {
        return 16
    }
    
    func isInternetAvailable() -> Bool {
        return modelBase.isInternetAvailable()
    }
}
