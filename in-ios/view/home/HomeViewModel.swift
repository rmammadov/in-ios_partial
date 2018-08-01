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
    
    fileprivate let requestHandler = ApiRequestHandler()
    fileprivate var menuItems: MenuItems?
    fileprivate var menuItemSelectedIndex: Int = 0
    fileprivate var isBackButtonHidden = true
    
    // TODO: Update this method

    func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.getMenuItems() != nil {
                self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
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
    
    func getTopMenuItems() -> Array<MenuItem>? {
        return self.menuItems?.getTopMenuItems()
    }
    
    func onTopMenuItemSelected(index: Int) {
        self.menuItemSelectedIndex = index
    }
    
    func getTopMenuItemSelected() -> Int {
        return self.menuItemSelectedIndex
    }
    
    func getSubMenuItemsOfSelection() -> Array<MenuItem>? {
        let menuItemSelected = self.getTopMenuItems()![0]
        return self.menuItems?.getSubMenuOf(item: menuItemSelected)
    }
    
    func setBackButtonStatus(status: Bool) {
        self.isBackButtonHidden = status
    }
    
    func getBackButtonStatus() -> Bool {
        return self.isBackButtonHidden
    }
    
    func onClickBackButton() {

    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
}
