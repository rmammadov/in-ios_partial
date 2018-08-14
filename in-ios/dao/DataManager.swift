//
//  DataManager.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/13/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

enum DataStatus: Int {
    case notLoaded = 0
    case menuItemsLoaded = 1
    case inputScreensLoaded = 2
    case dataLoadingCompleted = 3
}

class DataManager {
    
    static var status = Variable<Int>(0)
    
    static fileprivate var menuItems: MenuItems?
    static fileprivate var inputScreens: InputScreens?
    static fileprivate let requestHandler = ApiRequestHandler()
    
    static func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.status.value == RequestStatus.requestCompleted.rawValue {
                if self.requestHandler.getMenuItems().count != 0 && self.status.value == DataStatus.notLoaded.rawValue {
                    self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
                    self.status.value = DataStatus.menuItemsLoaded.rawValue
                    self.loadInputScreens()
                } else if self.requestHandler.getInputScreens().count != 0 {
                    self.inputScreens = InputScreens(screens: self.requestHandler.getInputScreens())
                    self.status.value = DataStatus.dataLoadingCompleted.rawValue
                }
            }
        })
    }
    
    static func loadRequiredData() {
        self.loadMenuItems()
    }
    
    static func loadMenuItems() {
        self.requestHandler.requestMenuItems()
    }
    
    static func getMenuItems() -> MenuItems {
        return self.menuItems!
    }
    
    static func loadInputScreens() {
        self.requestHandler.requestInputScreens()
    }
    
    static func getInputScreens() -> InputScreens {
        return self.inputScreens!
    }
}
