//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SubMenuViewModel: NSObject {

    var status = Variable<Int>(0)
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var items: Array<MenuItem> = []
    fileprivate var indexSelectedItem: IndexPath = IndexPath(row: 0, section: 0)
    
    func setSubscribers() {
        
    }
    
    func setParentMenuItem(item: MenuItem) {
        self.parentMenuItem = item
    }
    
    func getTitle() -> String? {
        return self.parentMenuItem?.translations[0].label
    }
    
    func setItems(items: [MenuItem]) {
        self.items = items
    }
    
    func getItmes() -> [MenuItem] {
        return self.items
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath {
        return self.indexSelectedItem
    }
}
