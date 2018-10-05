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
    var statusInput = Variable<Int>(0)
    
    var parentVC: HomeViewController?
    
    fileprivate var screen: InputScreen?
    fileprivate var parentMenuItem: MenuItem?
    var inputScreen: InputScreen?
    fileprivate var items: Array<ButtonInputScreen> = []
    fileprivate var groupedItems: Array<Array<ButtonInputScreen>> = []
    fileprivate var item: ButtonInputScreen?
    fileprivate var selectedItem: ButtonInputScreen?
    fileprivate var indexSelectedItem: IndexPath = IndexPath(row: 0, section: 0)
    fileprivate var page: Int = 0
    
    func setParentMenuItem(item: MenuItem) {
        parentMenuItem = item
    }
    
    func loadScreen() {
        if let parentMenuItem = parentMenuItem {
            self.screen = DataManager.getInputScreens().getInputScreen(title: parentMenuItem.name)
            
            if (screen?.buttons?.count)! > 0 {
                items = (screen?.buttons)!
                setGroupedItems(items: items)
            }
        } else if let inputScreen = inputScreen {
            self.screen = inputScreen
            if (screen?.buttons?.count) ?? 0 > 0 {
                items = (screen?.buttons)!
                setGroupedItems(items: items)
            }
        }
    }
    
    func setParentVC(vc: HomeViewController?) {
        self.parentVC = vc
    }
    
    func getBackground() -> String? {
        return screen?.background?.url
    }
    
    func getBackgroundTransparency() -> Double? {
        return screen?.backgroundTransparency
    }
    
    func getTitle() -> String? {
        return screen?.translations[0].title
    }
    
    func getBackButtonStatus() -> Bool? {
        guard let screen = screen else { return false }
        return screen.backButton != nil || screen.type == .inputScreenB
    }
    
    func getSpeakButtonStatus() -> Bool? {
        return false
    }
    
    func getPreviousButton() -> ButtonInputScreen? {
        return screen?.previousButton
    }
    
    func getNextButton() -> ButtonInputScreen? {
        return screen?.nextButton
    }
    
    func setItems(items: [ButtonInputScreen]?) {
    }
    
    func getItems() -> [ButtonInputScreen] {
        return items
    }
    
    func setPage(page: Int) {
        self.page = page
    }
    
    func getPage() -> Int {
        return page
    }
    
    func setGroupedItems(items: [ButtonInputScreen]) {
        let countItemsPerPage = (getRowCount()) * (getColumnCount())
        var countItems = getItems().count
        
        if countItems <= countItemsPerPage {
            return groupedItems = [items]
        } else {
            var startingIndex: Int = 0
            
            while countItems > 0 {
                var countNavigationItems: Int = 1
                
                if groupedItems.count > 0 {
                    countNavigationItems = 2
                } else {
                    countNavigationItems = 1
                }
                
                countItems = countItems - (countItemsPerPage - countNavigationItems)
                var subItems: Array<ButtonInputScreen> = []
                if countItems > countNavigationItems {
                    subItems = Array(getItems()[startingIndex...startingIndex + countItemsPerPage - countNavigationItems - 1])
                    if groupedItems.count > 0 {  // If it is not first page add previous button also
                       subItems.append(getPreviousButton()!)
                    }
                    subItems.append(getNextButton()!) // Add next button
                    startingIndex = startingIndex + countItemsPerPage - countNavigationItems
                } else {
                    subItems = Array(getItems()[startingIndex...getItems().count - 1])
                    subItems.append(getPreviousButton()!) // Add previous button
                }
                
                groupedItems.append(subItems)
            }
        }
    }
    
    func getGroupedItems() -> [[ButtonInputScreen]] {
        return groupedItems
    }
    
    func setItem(index: Int) {
        item = getGroupedItems()[getPage()][index]
    }
    
    func getItemTitle() -> String? {
        return item?.translations!.first!.label
    }
    
    func getItemIcon() -> String? {
        return item?.icon?.url
    }
    
    func setSelection(indexPath: IndexPath) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath {
        return indexSelectedItem
    }
    
    // FIXME: Fix and update
    
    func onItemLoadRequest(indexPath: IndexPath) {
        let item = getGroupedItems()[getPage()][indexPath.row]
        self.selectedItem = item
        
        guard let selectedItem = self.selectedItem else { return }
        
        if !(selectedItem.disableTextToSpeech ?? true) {
            textToSpech(text: (selectedItem.translations!.first?.labelTextToSpeech)!)
        }
        
        if selectedItem.translations?.first?.label == Constant.MenuConfig.PREVIOUS_ITEM_NAME {
            setPage(page: getPage() - 1)
        } else if selectedItem.translations?.first?.label == Constant.MenuConfig.NEXT_ITEM_NAME {
            setPage(page: getPage() + 1)
        }
        
        if selectedItem.type == ButtonInputScreen.ButtonType.inputScreenOpen,
            let inputScreenId = selectedItem.inputScreenId,
            let inputScreen = DataManager.getInputScreens().getInputScreenFor(id: inputScreenId) {
            
            switch inputScreen.type {
            case .inputScreenB:
                self.statusInput.value = InputScreenId.inputScreen0.rawValue
            case .inputScreenC:
                self.statusInput.value = InputScreenId.inputScreen1.rawValue
            default: break
            }
            
        }
        if selectedItem.type == .simple, let firstLabel = selectedItem.translations?.first?.label {
            switch firstLabel {
            case "Volume up":
                SpeechHelper.volumeUp()
            case "Volume down":
                SpeechHelper.volumeDown()
            default: break
            }
        }
        
        self.status.value = InputAStatus.loaded.rawValue
    }
    
    func loadInputScreenItem() -> InputScreen? {
        guard let selectedItem = selectedItem,
            let inputScreenId = selectedItem.inputScreenId
            else { return nil }
        return DataManager.getInputScreens().getInputScreenFor(id: inputScreenId)
    }
    
    // FIXME: Remove hardcode language type
    
    func textToSpech(text: String) {
        SpeechHelper.play(text: text, language: "en-US")
    }
}
