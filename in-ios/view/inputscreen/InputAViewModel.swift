//
//  InputViewModel.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

enum InputAStatus: Int {
    case notLoaded = 0
    case loaded = 1
}

class InputAViewModel: BaseViewModel {

    var status = Variable<Int>(0)
    
    fileprivate var screen: InputScreen?
    fileprivate var parentMenuItem: MenuItem?
    fileprivate var items: Array<ButtonInputScreen> = []
    fileprivate var button: ButtonInputScreen?
    fileprivate var indexSelectedItem: IndexPath = IndexPath(row: 0, section: 0)
    
    func setParentMenuItem(item: MenuItem) {
        self.parentMenuItem = item
    }
    
    func loadScreen() {
        self.screen = DataManager.getInputScreens().getInputScreenA()
        if (self.screen?.buttons?.count)! > 0 {
            self.items = (self.screen?.buttons)!
        }
    }
    
    func getTitle() -> String? {
        return self.screen?.translations[0].title
    }
    
    func getSpeakButtonStatus() -> Bool? {
        return self.screen?.disableTextToSpeech
    }
    
    func setItems(buttons: [ButtonInputScreen]?) {
        if buttons != nil {
            self.items = buttons!
        }
    }
    
    func getItmes() -> [ButtonInputScreen] {
        return self.items
    }

    func setItem(index: Int) {
        self.button = self.items[index]
    }
    
    func getItemTitle() -> String? {
        return self.button?.translations![0].label
    }
    
    func getItemIcon() -> String? {
        return self.button?.icon?.url
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath {
        return self.indexSelectedItem
    }
}
