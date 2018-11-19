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
    fileprivate var indexSelectedItem: IndexPath?
    fileprivate var page: Int = 0
    var selectionButton: UIButton?
    
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
        return screen?.translations.currentTranslation()?.label
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
        if item?.translations?.currentTranslation()?.label == Constant.MenuConfig.NAME_IAM_MENU_ITEM,
            let name = DataManager.getUserData()?.name {
            return item?.translations?.currentTranslation()?.label.replacingOccurrences(of: "<first name>", with: name)
        }
        return item?.translations?.currentTranslation()?.label
    }
    
    func getItemIcon() -> String? {
        return item?.icon?.url
    }
    
    func setSelection(indexPath: IndexPath?) {
        self.indexSelectedItem = indexPath
    }
    
    func getSelection() -> IndexPath? {
        return indexSelectedItem
    }
    
    // FIXME: Fix and update
    
    func onItemLoadRequest(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        let item = getGroupedItems()[getPage()][indexPath.row]
        self.selectedItem = item
        
        guard let selectedItem = self.selectedItem else { return }
        
        if !(selectedItem.disableTextToSpeech ?? true),
            let translation = selectedItem.translations?.currentTranslation() {
            if translation.labelTextToSpeech.contains("<first name>"), let name = DataManager.getUserData()?.name {
                let newTranslation = Translation(locale: translation.locale,
                                                 label: translation.label,
                                                 textToSpeech: translation.labelTextToSpeech.replacingOccurrences(of: "<first name>", with: name))
                SpeechHelper.shared.play(translation: newTranslation)
            } else {
                SpeechHelper.shared.play(translation: translation)
            }
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
            case Constant.MenuConfig.VOLUME_UP:
                SpeechHelper.shared.volumeUp()
            case Constant.MenuConfig.VOLUME_DOWN:
                SpeechHelper.shared.volumeDown()
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
    
}
