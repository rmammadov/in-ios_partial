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
    var inputScreen: InputScreen!
    weak var delegate: ScreenTypeCDelegate?
    private var items: [Bubble] = []
    private var selectedBubble = Variable<Bubble?>(nil)
    
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
    
    func setSelectedBubble(_ bubble: Bubble?) {
        selectedBubble.value = bubble
        if let selectedBubble = bubble {
            if !selectedBubble.isDisableTextToSpeech,
                let text = selectedBubble.translations.first?.labelTextToSpeech {
                SpeechHelper.play(text: text, language: "en-US")
            }
            delegate?.didSelect(value: selectedBubble, onScreen: inputScreen)
        }
    }
    
    func getSelectedBubble() -> Bubble? {
        return selectedBubble.value
    }
    
    func getSelectedBubbleObservable() -> Observable<Bubble?> {
        return selectedBubble.asObservable()
    }

}
