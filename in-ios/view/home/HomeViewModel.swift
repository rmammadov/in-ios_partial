//
//  HomeViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

enum TopMenuStatus: Int {
    case notLoaded = 0
    case loaded = 1
}

class HomeViewModel: BaseViewModel {
    
    // TODO: Get data types from model class
    
    var status = Variable<Int>(0)
    var isBackBtnClicked = Variable<Int>(0)
    
    fileprivate let requestHandler = ApiRequestHandler()
    fileprivate var menuItems: MenuItems?
    fileprivate var topMenuItems: [MenuItem] = []
    fileprivate var topMenuItemSelectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate var isBackButtonHidden = true
    
    // TODO: Update this method

    func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
             print("Printing JSON 0")
            if self.requestHandler.getMenuItems() != nil {
                print("Printing JSON 1")
                self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
                self.setTopMenuItems()
                self.status.value = TopMenuStatus.loaded.rawValue
            }
        })
    }
    
    func requestData() {
        self.requestHandler.requestMenuItems()
    }
    
    func getMenuItems() -> Array<MenuItem>? {
        return self.menuItems?.getMenuItems()
    }
    
    func setTopMenuItems() {
        self.topMenuItems = (self.menuItems?.getTopMenuItems())!
    }
    
    func getTopMenuItems() -> Array<MenuItem>? {
        return self.topMenuItems
    }
    
    func onTopMenuItemSelected(indexPath: IndexPath) {
        self.topMenuItemSelectedIndex = indexPath
        self.status.value = TopMenuStatus.loaded.rawValue
    }
    
    func getTopMenuItemSelected() -> IndexPath {
        return self.topMenuItemSelectedIndex
    }
    
    func getSubMenuItemsOfSelected(menuItem: MenuItem) -> Array<MenuItem>? {
        return self.menuItems?.getSubMenuOf(item: menuItem)
    }
    
    func setBackButtonStatus(status: Bool) {
        self.isBackButtonHidden = status
    }
    
    func getBackButtonStatus() -> Bool {
        return self.isBackButtonHidden
    }
    
    func onClickBackButton() {
        self.isBackBtnClicked.value += 1
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
}
