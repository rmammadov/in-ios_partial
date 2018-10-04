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
    var selectedItem = Variable<[Int: ButtonInputScreen]>([:])
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
        let viewModel = ScreenTypeCMenuCollectionViewCell.ViewModel(selectedTranslations: selectedItem.value[item.id]?.translations,
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
        prepareViewControllers()
    }
    
    private func prepareViewControllers() {
        for item in getItems() {
            if let vc = loadViewControllerFor(item: item) {
                viewControllers.append(vc)
            }
        }
    }
    
    private func loadViewControllerFor(item: InputScreen) -> UIViewController? {
        let storyboard = UIStoryboard(name: "ScreenTypeC", bundle: nil)
        switch item.type {
        case Constant.InputScreen.TYPE_E:
            if let vc = storyboard.instantiateViewController(withIdentifier: ScreenTypeEViewController.identifier) as? ScreenTypeEViewController {
                vc.viewModel.inputScreen = item
                vc.viewModel.delegate = self
                return vc
            }
        default:
            return UIViewController()
        }
        return nil
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
    
    func speakSelectedValues() {
        for item in items.value {
            if let selectedValue = selectedItem.value[item.id],
                let text = selectedValue.translations?.first?.labelTextToSpeech {
                SpeechHelper.play(text: text, language: "en-US")
            }
        }
    }
}

extension ScreenTypeCViewModel: ScreenTypeCDelegate {
    func didSelect(button: ButtonInputScreen, onScreen: InputScreen) {
        selectedItem.value[onScreen.id] = button
    }
}


