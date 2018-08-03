//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum SubMenuStatus: Int {
    case notLoaded = 0
    case firstPhaseLoaded = 1
    case secondPhaseLoaded = 2
}

class SubMenuViewModel: BaseViewModel {
    
    // TODO: Get data types from model class
    
    var status = Variable<Int>(0)
    
    fileprivate var parentVC: HomeViewController?
    fileprivate var subMenuItems: [MenuItem] = []
    fileprivate var indexPathPerviousSelection: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate var isBackBtnHidden = true
    
    func setSubscribers() {
        self.parentVC?.viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.parentVC?.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                self.loadInitalMenuItems()
            }
        })
        
        self.parentVC?.viewModel.isBackBtnClicked.asObservable().subscribe(onNext: {
            event in
            if self.parentVC?.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                self.loadInitalMenuItems()
            }
        })
    }
    
    func setParentVC(vc: HomeViewController) {
        self.parentVC = vc
    }
    
    func getParentVC() -> HomeViewController? {
        return self.parentVC
    }
    
    func loadInitalMenuItems() {
        let selectedTopMenuItemIndex = self.parentVC?.viewModel.getTopMenuItemSelected().row
        let selectedTopMenuItem = self.parentVC?.viewModel.getTopMenuItems()![selectedTopMenuItemIndex!]
        self.loadSubMenuItemsOf(menuItem: selectedTopMenuItem!, topMenuClicked: true)
        self.status.value = SubMenuStatus.firstPhaseLoaded.rawValue
    }
    
    func loadSubMenuItemsOf(menuItem: MenuItem, topMenuClicked: Bool) {
        let items = (self.parentVC?.viewModel.getSubMenuItemsOfSelected(menuItem: menuItem))!
        if items.count != 0 || topMenuClicked {
            self.setSubMenuItems(items: items)
            if !topMenuClicked {
                self.status.value = SubMenuStatus.secondPhaseLoaded.rawValue
            }
        } else {
            if !menuItem.disable_text_to_speech {
                self.textToSpech(text: menuItem.translations[0].label_text_to_speech!)
            }
        }
    }
    
    func setSubMenuItems(items: [MenuItem]) {
        self.subMenuItems = items
    }
    
    func getSubMenuItems() -> [MenuItem]? {
        return self.subMenuItems
    }
    
    // FIXME: Fix and update
    
    func onItemLoadRequest(indexPath: IndexPath) {
        let menuItem = self.getSubMenuItems()![indexPath.row]
        self.loadSubMenuItemsOf(menuItem: menuItem, topMenuClicked: false)
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexPathPerviousSelection = indexPath
    }
    
    func getSelection() -> IndexPath {
        return self.indexPathPerviousSelection
    }
    
    func getIsBackBtnHidden() -> Bool {
        switch self.status.value {
        case SubMenuStatus.firstPhaseLoaded.rawValue:
            self.isBackBtnHidden = true
        case SubMenuStatus.secondPhaseLoaded.rawValue:
            self.isBackBtnHidden = false
        default:
            self.isBackBtnHidden = true
        }
        
        return self.isBackBtnHidden
    }
}
