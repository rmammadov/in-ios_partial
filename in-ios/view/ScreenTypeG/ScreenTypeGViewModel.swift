//
//  ScreenTypeGViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 22/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeGViewModel: BaseViewModel {
    
    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    private var items = [ButtonInputScreen]()
    var selectedIndex: IndexPath?
    var newSelectedIndex: IndexPath?
    private var selectionIndexPath: IndexPath?
    
    func loadItems() {
        guard let buttons = inputScreen.buttons else { return }
        items = buttons
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
  
    func getItems() -> [ButtonInputScreen] {
        return items
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
