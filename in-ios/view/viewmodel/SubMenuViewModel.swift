//
//  SubMenuViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SubMenuViewModel: NSObject {
    
    var status = Variable<Int>(0)
    
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var indexPathPerviousSelection: IndexPath = IndexPath(row: 0, section: 0)
    
//    init(parentMenuItem: MenuItem) {
//        self.parentMenuItem = parentMenuItem
//    }
    
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
    
    func textToSpech() {
        SpeechHelper.play(text: "You can omit the rate property entirely to have a natural-speed voice, or change the language to (English, American accent)(English, Australian accent) or whichever other accents Apple chooses to add in the future.", language: "en-US")
    }
}
