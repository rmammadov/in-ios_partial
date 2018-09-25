//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SubMenuViewModel: BaseViewModel {

    var status = Variable<Int>(0)
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var items: Array<MenuItem> = []
    fileprivate var item: MenuItem?
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
    
    func setItem(index: Int) {
        self.item = self.items[index]
    }
    
    func getItemTitle() -> String? {
        return self.item?.translations[0].label
    }
    
    func getItemIcon() -> String? {
        return self.item?.icon?.url
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath {
        return self.indexSelectedItem
    }
}
