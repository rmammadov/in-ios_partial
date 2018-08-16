//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum MenuStatus: Int {
    case notLoaded = 0
    case firstPhaseLoaded = 1
    case secondPhaseLoaded = 2
}

enum InputScreenId: Int {
    case inputScreen0 = 10
    case inputScreen1 = 11
    case inputScreen2 = 12
}

class MenuViewModel: BaseViewModel {
    
    // TODO: Get data types from model class
    
    var status = Variable<Int>(0)
    var statusInput = Variable<Int>(0)
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var parentVC: HomeViewController?
    fileprivate var items: [MenuItem] = []
    fileprivate var indexSelectedItem: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate var selectedItem: MenuItem?
    
    // TODO: Change Rxsift to callbacks
    
    func setSubscribers() {
        self.parentVC?.viewModel.status.asObservable().subscribe( onNext: {
            event in
            if self.parentVC?.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                self.setParentMenuItem(item: self.parentVC?.viewModel.getTopMenuItemSelected())
                self.loadInitalMenuItems()
            }
        })
    }
    
    func setParentMenuItem(item: MenuItem?) {
        self.parentMenuItem = item
    }
    
    func setParentVC(vc: HomeViewController?) {
        self.parentVC = vc
    }
    
    func loadInitalMenuItems() {
        if parentMenuItem != nil {
            self.loadSubMenuItemsOf(menuItem: self.parentMenuItem!, topMenuClicked: true)
            self.status.value = MenuStatus.firstPhaseLoaded.rawValue
            }
    }
    
    func getIAMItem() -> Int {
        return DataManager.getMenuItems().getIAMItemIndex()
    }
    
    func getSubItemsOf(item: MenuItem) -> [MenuItem] {
        return DataManager.getMenuItems().getSubMenuOf(item: item)!
    }
    
    func loadSubMenuItemsOf(menuItem: MenuItem, topMenuClicked: Bool) {
        let items = self.getSubItemsOf(item: menuItem)
        if items.count != 0 || topMenuClicked {
            if !topMenuClicked {
                self.status.value = MenuStatus.secondPhaseLoaded.rawValue
            } else {
                self.setMenuItems(items: items)
            }
        } else {
            if menuItem.input_screen_id != nil {
                self.statusInput.value = InputScreenId.inputScreen0.rawValue
            } else {
                if !menuItem.disable_text_to_speech {
                    self.textToSpech(text: menuItem.translations[0].label_text_to_speech!)
                }
            }
        }
    }
    
    func setMenuItems(items: [MenuItem]) {
        self.items = items
    }
    
    func getMenuItems() -> [MenuItem]? {
        return self.items
    }
    
    // FIXME: Fix and update
    
    func onItemLoadRequest(indexPath: IndexPath) {
        let menuItem = self.getMenuItems()![indexPath.row]
        self.selectedItem = menuItem
        self.loadSubMenuItemsOf(menuItem: menuItem, topMenuClicked: false)
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath {
        return self.indexSelectedItem
    }
    
    func getSelectedItem() -> MenuItem? {
        return self.selectedItem
    }
}
