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
    case legalDocumentsLoaded = 4
    case dataLoadingCompleted = 5
}

class DataManager {
    
    static var status = Variable<Int>(0)
    static let disposeBag = DisposeBag()
    
    static fileprivate var menuItems: MenuItems?
    static fileprivate var inputScreens: InputScreens?
    static fileprivate var legalDocuments: LegalDocuments?
    static fileprivate let requestHandler = ApiRequestHandler()
    
    static func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.status.value != RequestStatus.failed.rawValue{
                if self.requestHandler.status.value == RequestStatus.completedMenuItems.rawValue {
                    self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
                    self.loadInputScreens()
                    self.status.value = DataStatus.menuItemsLoaded.rawValue
                } else if self.requestHandler.status.value == RequestStatus.completedInputScreens.rawValue {
                    self.inputScreens = InputScreens(screens: self.requestHandler.getInputScreens())
                    self.loadLegalDocuments()
                    self.status.value = DataStatus.inputScreensLoaded.rawValue
                } else if self.requestHandler.status.value == RequestStatus.completedLegalDocuments.rawValue {
                    self.legalDocuments = LegalDocuments(legalDocuments: self.requestHandler.getLegalDocuments())
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
    
    static func loadLegalDocuments() {
        self.requestHandler.requestLegalDocuments()
    }
    
    static func getLegalDocuments() -> LegalDocuments {
        return self.legalDocuments!
    }
}
