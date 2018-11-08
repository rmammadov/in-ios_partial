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
        self.newBodyRow = nil
        self.selectedBubble = bubble
        self.newBubble = nil
        
        if !bubble.isDisableTextToSpeech {
            SpeechHelper.shared.play(translation: bubble.translations.currentTranslation())
        }
        delegate?.didSelect(value: bubble, onButton: button)
    }

}
