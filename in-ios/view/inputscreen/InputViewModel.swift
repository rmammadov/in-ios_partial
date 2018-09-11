//
//  InputViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class InputAViewModel: BaseViewModel {

    fileprivate var parentMenuItem: MenuItem?
    
    func setParentMenuItem(item: MenuItem) {
        self.parentMenuItem = item
    }
    
    func getTitle() -> String? {
        return self.parentMenuItem?.translations[0].label
    }
}
