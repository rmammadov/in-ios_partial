//
//  ScreenTypeCViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 02/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

class ScreenTypeCViewModel: BaseViewModel {
    
    var items = Variable<[InputScreen]>([])
    var inputScreen: InputScreen?
    var selectedItem = Variable<[String: ButtonInputScreen]>([:])
    var selectedIndexPath = Variable<IndexPath?>(nil)
    var viewControllers: [UIViewController] = []
    
    func getItems() -> [InputScreen] {
        return items.value
    }
    
    func getClearButton() -> ButtonInputScreen? {
        return inputScreen?.clearButton
    }
    
    func getItemViewModelFor(indexPath: IndexPath) -> ScreenTypeCMenuCollectionViewCell.ViewModel? {
        guard getItems().count > indexPath.item else { return nil }
        let item = getItems()[indexPath.item]
        guard let title = item.translations.first?.title else { return nil }
        let viewModel = ScreenTypeCMenuCollectionViewCell.ViewModel(selectedTranslations: selectedItem.value[title]?.translations,
                                                                    translations: item.translations)
        return viewModel
    }
    
    func setInputScreen(_ inputScreen: InputScreen) {
        self.inputScreen = inputScreen
    }
    
    func loadItems() {
        guard let inputScreen = inputScreen else { return }
        loadItemsFor(inputScreen: inputScreen)
    }
    
    private func loadItemsFor(inputScreen: InputScreen) {
        var items: [InputScreen] = []
        inputScreen.tabs?.forEach({
            if let inputScreen = DataManager.getInputScreens().getInputScreenFor(id: $0.panelScreenId) {
                items.append(inputScreen)
            }
         })
        setItems(items: items)
        
        //TODO: Hardcoded screen, change this if we will have prepared Screens D, E, F and so on.
        let storyboard = UIStoryboard(name: "ScreenTypeC", bundle: nil)
        for i in 0..<items.count {
            viewControllers.append(storyboard.instantiateViewController(withIdentifier: "\((i % 3) + 1)"))
        }
    }
    
    private func setItems(items: [InputScreen]) {
        self.items.value = items
    }
    
    func getSelectedViewController() -> UIViewController? {
        guard let index = selectedIndexPath.value?.item,
            viewControllers.count > index
            else { return nil }
        return viewControllers[index]
    }
}


