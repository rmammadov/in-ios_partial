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
    case topMenuShown = 1
    case subMenuShown = 2
}

class SubMenuViewModel: BaseViewModel {
    
    // TODO: Get data types from model class
    
    var status = Variable<Int>(0)
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var indexPathPerviousSelection: IndexPath = IndexPath(row: 0, section: 0)
    
//    init(parentMenuItem: MenuItem) {
//        self.parentMenuItem = parentMenuItem
//    }
    
    // FIXME: Fix and update 
    
    func onItemClicked(indexPath: IndexPath) {
        self.setPreviousSelection(indexPath: indexPath)
        self.textToSpech()
    }
    
    func setPreviousSelection(indexPath: IndexPath) {
        self.indexPathPerviousSelection = indexPath
    }
    
    func getPreviousSelection() -> IndexPath {
        return self.indexPathPerviousSelection
    }
    
    func getBack() {
        self.status.value = SubMenuStatus.topMenuShown.rawValue
    }
}
