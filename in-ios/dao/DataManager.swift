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
    case dataLoadingFailed = 1
    case menuItemsLoaded = 2
    case inputScreensLoaded = 3
    case dataLoadingCompleted = 4
}

class DataManager {
    
    static var status = Variable<Int>(0)
    static let disposeBag = DisposeBag()
    
    static fileprivate var menuItems: MenuItems?
    static fileprivate var inputScreens: InputScreens?
    static fileprivate let requestHandler = ApiRequestHandler()
    
    static func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.status.value == RequestStatus.completed.rawValue {
                if self.requestHandler.getMenuItems().count != 0 && self.status.value == DataStatus.notLoaded.rawValue {
                    self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
                    self.loadInputScreens()
                    self.status.value = DataStatus.menuItemsLoaded.rawValue
                } else if self.requestHandler.getInputScreens().count != 0 {
                    self.inputScreens = InputScreens(screens: self.requestHandler.getInputScreens())
                    self.status.value = DataStatus.dataLoadingCompleted.rawValue
                }
            } else if self.requestHandler.status.value == RequestStatus.failed.rawValue {
                self.status.value = DataStatus.dataLoadingFailed.rawValue
            }
        }).disposed(by: disposeBag)
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
