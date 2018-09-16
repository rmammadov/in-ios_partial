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
        setTopMenuItems(items: DataManager.getMenuItems().getTopMenuItems()!)
        onTopMenuItemSelected(indexPath: topMenuItemSelectedIndex)
    }
    
    func setTopMenuItems(items: [MenuItem]) {
        topMenuItems = items
    }
    
    func getTopMenuItems() -> Array<MenuItem>? {
        return topMenuItems
    }
    
    func setItem(index: Int) {
        topMenuItem = topMenuItems[index]
    }
    
    func getItemTitle() -> String? {
        return topMenuItem?.translations[0].label
    }
    
    func getItemIcon() -> String? {
        return topMenuItem?.icon?.url
    }
    
    func onTopMenuItemSelected(indexPath: IndexPath) {
        topMenuItemSelected = getTopMenuItems()?[indexPath.row]
        topMenuItemSelectedIndex = indexPath
        
        if !(topMenuItemSelected?.disableTextToSpeech)! {
            textToSpech(text: (topMenuItemSelected?.translations.first?.labelTextToSpeech)!)
        }
        
        status.value = TopMenuStatus.loaded.rawValue
    }
    
    func getTopMenuItemSelected() -> IndexPath {
        return topMenuItemSelectedIndex
    }
    
    func getTopMenuItemSelected() -> MenuItem? {
        return topMenuItemSelected
    }
    
    func getIsMenuExpanded() -> Bool {
        return isMenuExpanded
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
}
