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
    
    fileprivate var topMenuItems: [MenuItem] = []
    fileprivate var topMenuItem: MenuItem?
    fileprivate var topMenuItemSelectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate var topMenuItemSelected: MenuItem?
    fileprivate var isMenuExpanded: Bool = true
    
    // TODO: Update this method

    func setSubscribers() {

    }
    
    func setData() {
        self.setTopMenuItems(items: DataManager.getMenuItems().getTopMenuItems()!)
        self.onTopMenuItemSelected(indexPath: self.topMenuItemSelectedIndex)
    }
    
    func setTopMenuItems(items: [MenuItem]) {
        self.topMenuItems = items
    }
    
    func getTopMenuItems() -> Array<MenuItem>? {
        return self.topMenuItems
    }
    
    func setItem(index: Int) {
        self.topMenuItem = self.topMenuItems[index]
    }
    
    func getItemTitle() -> String? {
        return self.topMenuItem?.translations[0].label
    }
    
    func getItemIcon() -> String? {
        return self.topMenuItem?.icon?.url
    }
    
    func onTopMenuItemSelected(indexPath: IndexPath) {
        self.topMenuItemSelected = self.getTopMenuItems()?[indexPath.row]
        self.topMenuItemSelectedIndex = indexPath
        self.status.value = TopMenuStatus.loaded.rawValue
    }
    
    func getTopMenuItemSelected() -> IndexPath {
        return self.topMenuItemSelectedIndex
    }
    
    func getTopMenuItemSelected() -> MenuItem? {
        return self.topMenuItemSelected
    }
    
    func getIsMenuExpanded() -> Bool {
        return self.isMenuExpanded
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
}
