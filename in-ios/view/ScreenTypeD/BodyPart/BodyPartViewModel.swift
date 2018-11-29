//
//  BodyPartViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 09/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class BodyPartViewModel: BaseViewModel {

    var button: ButtonInputScreen!
    weak var delegate: ScreenTypeDDelegate?
    private var items: [Bubble] = []
    var newBubble: Bubble?
    var newBodyRow: BodyPartRowView?
    var selectedBubble: Bubble?
    var selectedBodyRow: BodyPartRowView?
    
    func loadItems() {
        guard let bubbles = button.bubbles, bubbles.count > 0 else { return }
        items = bubbles
    }
    
    func getItems() -> [Bubble] {
        return items
    }
    
    func getImageUrl() -> URL? {
        return button.picture?.url
    }
    
    func onSelectionComplete() {
        guard let bubble = newBubble, let row = newBodyRow  else { return }
        self.selectedBodyRow = row
        self.selectedBubble = bubble
        
        if !bubble.isDisableTextToSpeech {
            SpeechHelper.shared.play(translation: bubble.translations.currentTranslation())
        }
        delegate?.didSelect(value: bubble, onButton: button)
        saveUsage(bubble: bubble)
    }
    
    private func saveUsage(bubble: Bubble) {
        let locale = bubble.translations.currentTranslation()?.locale ?? "en"
        let label = bubble.translations.currentTranslation()?.label ?? ""
        let itemType = "Bubble"
        let itemId = bubble.id
        let tileContext = button.translations?.first?.label ?? ""
        DatabaseWorker.shared.addUsage(locale: locale, label: label, itemType: itemType, itemId: itemId, tileContext: tileContext)
    }

}
