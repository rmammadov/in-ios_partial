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
    
    func setSubscribers() {
        self.parentVC?.viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.parentVC?.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                self.setSubMenuItems()
                self.status.value = SubMenuStatus.firstPhaseLoaded.rawValue
            }
        })
    }
    
    func setParentVC(vc: HomeViewController) {
        self.parentVC = vc
    }
    
    func setSubMenuItems() {
        self.subMenuItems = (self.parentVC?.viewModel.getSubMenuItemsOfSelection())!
    }
    
    func getSubMenuItems() -> [MenuItem]? {
        return self.subMenuItems
    }
    
    // FIXME: Fix and update
    
    func onItemClicked(indexPath: IndexPath) {
        let menuItem = self.getSubMenuItems()![indexPath.row]
        self.setPreviousSelection(indexPath: indexPath)
        if !menuItem.disable_text_to_speech {
            self.textToSpech(text: menuItem.translations[0].label_text_to_speech!)
        }
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
    
    func setPreviousSelection(indexPath: IndexPath) {
        self.indexPathPerviousSelection = indexPath
    }
    
    func getPreviousSelection() -> IndexPath {
        return self.indexPathPerviousSelection
    }
    
    func getBack() {
     
    }
}
