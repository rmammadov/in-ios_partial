//
//  BodyPartViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 09/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class BodyPartViewModel: BaseViewModel {

    var button: ButtonInputScreen!
    weak var delegate: ScreenTypeCDelegate?
    private var items: [Bubble] = []
    
    func loadItems() {
        guard let bubbles = button.bubbles, bubbles.count > 0 else { return }
        items = bubbles
    }
    
    func getItems() -> [Bubble] {
        return items
    }
}
