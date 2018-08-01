//
//  HomeViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/29/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

class HomeViewModel: BaseViewModel {
    
    var status = Variable<Int>(0)
    
    fileprivate let requestHandler = ApiRequestHandler()
    fileprivate var menuItems: MenuItems?
    fileprivate var vcSubMenu: SubMenuViewController?
    fileprivate var isBackButtonHidden = true
    
    func setSubscribers() {
        self.requestHandler.status.asObservable().subscribe(onNext: {
            event in
            if self.requestHandler.getMenuItems() != nil {
                self.menuItems = MenuItems(items: self.requestHandler.getMenuItems())
            }
        })
        
        self.getSubMenuVC()?.viewModel.status.asObservable().subscribe(onNext: {
            event in
            switch self.getSubMenuVC()?.viewModel.status.value {
            case SubMenuStatus.topMenuShown.rawValue:
                self.setBackButtonStatus(status: true)
            case SubMenuStatus.subMenuShown.rawValue:
                self.setBackButtonStatus(status: false)
            default:
                self.setBackButtonStatus(status: true)
            }
            
            self.status.value = (self.getSubMenuVC()?.viewModel.status.value)!
        })
    }
    
    func requestData() {
        self.requestHandler.requestMenuItems()
    }
    
    func getMenuItems() -> Array<MenuItem>? {
        return self.menuItems?.getMenuItems()
    }
    
    func getTopMenuItems() -> Array<MenuItem>? {
        return (self.menuItems?.getTopMenuItems())
    }
    
    func textToSpech(text: String) {
         SpeechHelper.play(text: text, language: "en-US")
    }
    
    func setSubMenuVC(vcSubMenu: SubMenuViewController) {
        self.vcSubMenu = vcSubMenu
    }
    
    func getSubMenuVC() -> SubMenuViewController? {
        return self.vcSubMenu
    }
    
    func setBackButtonStatus(status: Bool) {
        self.isBackButtonHidden = status
    }
    
    func getBackButtonStatus() -> Bool {
        return self.isBackButtonHidden
    }
    
    func onClickBackButton() {
        self.getSubMenuVC()?.viewModel.getBack()
    }
}
