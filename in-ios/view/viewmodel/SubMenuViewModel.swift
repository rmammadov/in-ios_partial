//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class SubMenuViewModel: NSObject {
    
    fileprivate var indexPathPerviousSelection: IndexPath = IndexPath(row: 0, section: 0)
    
    func setPreviousSelection(indexPath: IndexPath) {
        self.indexPathPerviousSelection = indexPath
    }
    
    func getPreviousSelection() -> IndexPath {
        return self.indexPathPerviousSelection
    }
}
