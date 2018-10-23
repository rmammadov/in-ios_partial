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
        let item = getItemAt(indexPath: selectedIndex)
        if !(item.disableTextToSpeech ?? true) {
            textToSpeech(item: item)
        }
        delegate?.didSelect(value: item, onScreen: inputScreen)
    }
    
    func getItemAt(indexPath: IndexPath) -> ButtonInputScreen {
        return items[indexPath.item]
    }
    
    func textToSpeech(item: ButtonInputScreen) {
        if let text = item.translations?.first?.labelTextToSpeech {
            SpeechHelper.play(text: text, language: Locale.current.languageCode!)
        }
    }
    
}
