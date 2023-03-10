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
    case settingsAccount = 13
    case settingsInterface = 14
}

class MenuViewModel: BaseViewModel {
    
    // TODO: Get data types from model class
    
    var status = Variable<Int>(0)
    var statusInput = Variable<Int>(0)
    let disposeBag = DisposeBag()
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var parentVC: HomeViewController?
    fileprivate var items: [MenuItem] = []
    fileprivate var item: MenuItem?
    fileprivate var indexSelectedItem: IndexPath?
    fileprivate var selectedItem: MenuItem?
    
    // TODO: Change Rxsift to callbacks
    
    func setSubscribers() {
        self.parentVC?.viewModel.status.asObservable().subscribe( onNext: {
            event in
            if self.parentVC?.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                self.setParentMenuItem(item: self.parentVC?.viewModel.getTopMenuItemSelected())
                self.loadInitalMenuItems()
            }
        }).disposed(by: disposeBag)
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
        guard let index = self.items.index(where: {$0.name == Constant.MenuConfig.NAME_IAM_MENU_ITEM}) else {return Constant.MenuConfig.IAM_NOT_FOUND_INDEX}
        return index
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
            switch menuItem.id {
            case 12:
                statusInput.value = InputScreenId.settingsInterface.rawValue
            case 13:
                statusInput.value = InputScreenId.settingsAccount.rawValue
            default:
                statusInput.value = InputScreenId.inputScreen0.rawValue
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
    
    func onItemLoadRequest(indexPath: IndexPath?) {
        guard let indexPath = indexPath, self.getMenuItems()?.count ?? 0 > indexPath.row else { return }
        
        let menuItem = self.getMenuItems()![indexPath.row]
        self.selectedItem = menuItem
        
        if !(selectedItem?.disableTextToSpeech)! {
            SpeechHelper.shared.play(translation: selectedItem?.translations.currentTranslation())
        }
        
        self.loadSubMenuItemsOf(menuItem: menuItem, topMenuClicked: false)
    }
    
    func setItem(index: Int) {
        self.item = self.items[index]
    }
    
    func getItemTitle() -> String? {
        return self.item?.translations.currentTranslation()?.label
    }
    
    func getItemIcon() -> String? {
        return self.item?.icon?.url
    }
    
    func setSelection(indexPath: IndexPath?) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath? {
        return self.indexSelectedItem
    }
    
    func getSelectedItem() -> MenuItem? {
        return self.selectedItem
    }
}
