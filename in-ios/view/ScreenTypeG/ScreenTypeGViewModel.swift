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
    }
  
    func getItems() -> [ButtonInputScreen] {
        return items
    }
    
    func getItemAt(indexPath: IndexPath) -> ButtonInputScreen {
        return items[indexPath.item]
    }
    
    func textToSpeech(item: ButtonInputScreen) {
        if let text = item.translations?.first?.labelTextToSpeech {
            SpeechHelper.shared.play(text: text, language: Locale.current.languageCode!)
        }
    }
}
