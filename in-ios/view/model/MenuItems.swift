//
//  MenuItems.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/31/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

struct MenuItems {
    
    let items: Array<MenuItem>?
}

extension MenuItems {
    
    func getMenuItems() -> Array<MenuItem>? {
        return self.items
    }
    
    func getTopMenuItems() -> Array<MenuItem>? {
        let menuItemTop = self.items?.filter{$0.name == Constant.menuConfiguration.NAME_TOP_MENU_ITEM}.first
        
        return self.getSubMenuOf(item: menuItemTop!)
    }
    
    func getSubMenuOf(item: MenuItem) -> Array<MenuItem>? {
        var menuItems: Array<MenuItem> = []
        for id in (item.sub_menu_item_item_ids) {
            menuItems.append((self.items?.filter{$0.id == id}.first)!)
        }
        
        return menuItems
    }
}
