//
//  ScreenTypeFViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation

class ScreenTypeFViewModel: BaseViewModel {
    
    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    private var items = [ButtonInputScreen]()
    var selectedIndex: IndexPath?
    var newSelectedIndex: IndexPath?
    private var selectionIndexPath: IndexPath?
    
    func loadItems() {
        guard let items = inputScreen?.buttons else { return }
        self.items = items
        reorderItems()
    }
    
    func getItems() -> [ButtonInputScreen] {
        return items
    }
    
    private func reorderItems() {
        var newOrderedItems = [ButtonInputScreen]()
        var tempArray = items
        while tempArray.count > 0 {
            let index = ((tempArray.count / 2) - 1) + (tempArray.count % 2)
            if index >= 0 {
                newOrderedItems.append(tempArray[index])
                tempArray.remove(at: index)
            }
            if let last = tempArray.popLast() {
                newOrderedItems.append(last)
            }
        }
        items = newOrderedItems
    }
    
    func onSelectionComplete() {
        guard let selectedIndex = newSelectedIndex else { return }
        self.selectedIndex = selectedIndex
        newSelectedIndex = nil
        var item = getItemAt(indexPath: selectedIndex)
        if !(item.disableTextToSpeech ?? true) {
            textToSpeech(item: item)
        }
        if let translations = item.translations {
            item.translations = translations.map({ (translationItem) -> Translation in
                return Translation(locale: translationItem.locale,
                                   label: translationItem.labelTextToSpeech,
                                   textToSpeech: translationItem.labelTextToSpeech)
            })
        }
        delegate?.didSelect(value: item, onScreen: inputScreen)
        saveUsage(item: item)
    }
    
    private func saveUsage(item: ButtonInputScreen) {
        let locale = item.translations?.currentTranslation()?.locale ?? "en"
        let label = item.translations?.currentTranslation()?.label ?? ""
        let itemType = item.type.rawValue
        let itemId = item.id
        let tileContext = inputScreen.translations.currentTranslation()?.label ?? ""
        DatabaseWorker.shared.addUsage(locale: locale, label: label, itemType: itemType, itemId: itemId, tileContext: tileContext)
    }
    
    func getItemAt(indexPath: IndexPath) -> ButtonInputScreen {
        return items[indexPath.item]
    }
    
    func textToSpeech(item: ButtonInputScreen) {
        SpeechHelper.shared.play(translation: item.translations?.currentTranslation())
    }
    
    func getSelection() -> IndexPath? {
        return selectionIndexPath
    }
    
    func setSelection(_ indexPath: IndexPath?) {
        selectionIndexPath = indexPath
    }
    
}
