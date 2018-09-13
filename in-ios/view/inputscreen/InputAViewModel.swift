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
    fileprivate var displayedArray = Array<ButtonInputScreen> ()
    var itemsCountOnPage = 20
    
    func setParentMenuItem(item: MenuItem) {
        self.parentMenuItem = item
    }
    
    func loadScreen() {
        self.screen = DataManager.getInputScreens().getInputScreen(title: (parentMenuItem?.name)!)
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
            self.displayedArray = buttons!
        }
    }
    
    func getItems(for page: NSInteger) -> [ButtonInputScreen] {
        
        displayedArray = []
        if (self.items.count > itemsCountOnPage) {
            
            if (page < 1) {
                displayedArray = Array(self.items[0..<itemsCountOnPage-1])
                displayedArray.append(addButton(previous: false))
            } else {
                if ((itemsCountOnPage-2)*page+1+itemsCountOnPage-2 > self.items.count) {
                    displayedArray.append(addButton(previous: true))
                    displayedArray.append(contentsOf:(self.items[itemsCountOnPage-1*page - (page >= 2 ? page-1 : 0)..<self.items.count]))
                    
                } else {
                    displayedArray.append(addButton(previous: true))
                    displayedArray.append(contentsOf: Array(self.items[itemsCountOnPage-1*page - (page >= 2 ? page-1 : 0)..<itemsCountOnPage-1*page+itemsCountOnPage - (page >= 3 ? page : 2)]))
                    displayedArray.append(addButton(previous: false))
                }
            }
        } else {
            displayedArray = self.items
        }
        
        return displayedArray
    }
    
    func addButton(previous: Bool) -> ButtonInputScreen {
        
        var button = ButtonInputScreen()
        button.translations = [TranslationMenuItem()]
        button.translations![0].label = previous ? "Previous" : "Next"
        button.icon = IconMenuItem()
        button.icon?.url = previous ? "https://cdn-beta1.innodem-neurosciences.com/upload/media/dev/button_icon/0001/01/e5ef0e37d1f7d0e808fdbc5d6fbcf3bebbf0bc75.png" : "https://cdn-beta1.innodem-neurosciences.com/upload/media/dev/button_icon/0001/01/64e1befbd58e7a6955aa2701f0dd6ee1f502b581.png"

        return button
    }
    
    func setItem(index: Int) {
        self.button = self.displayedArray[index]
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
