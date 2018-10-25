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
    var selectedItem = Variable<[Int: Any]>([:])
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
        var selectedText: String = ""
        let viewModel = ScreenTypeCMenuCollectionViewCell.ViewModel(selectedTranslations: getSelectedLabel(for: item.id),
                                                                    translations: item.translations)
        return viewModel
    }
    
    func getSelectedLabel(for index: Int) -> String? {
        if let item = selectedItem.value[index] as? ButtonInputScreen, let label = item.translations?.first?.label {
            return label
        } else if let item = selectedItem.value[index] as? Bubble, let label = item.translations.first?.label {
            return label
        }
        return nil
    }
    
    func getSelectedText(for index: Int) -> String? {
        if let item = selectedItem.value[index] as? ButtonInputScreen, let text = item.translations?.first?.labelTextToSpeech {
            return text
        } else if let item = selectedItem.value[index] as? Bubble, let text = item.translations.first?.labelTextToSpeech {
            return text
        }
        return nil
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch item.type {
        case .inputScreenE, .inputScreenH:
            if let vc = storyboard.instantiateViewController(withIdentifier: ScreenTypeEViewController.identifier) as? ScreenTypeEViewController {
                vc.viewModel.inputScreen = item
                vc.viewModel.delegate = self
                return vc
            }
        case .inputScreenF:
            if let vc = storyboard.instantiateViewController(withIdentifier: ScreenTypeFViewController.identifier) as? ScreenTypeFViewController {
                vc.viewModel.inputScreen = item
                vc.viewModel.delegate = self
                return vc
            }
        case .inputScreenD:
            if let vc = storyboard.instantiateViewController(withIdentifier: ScreenTypeDViewController.identifier) as? ScreenTypeDViewController {
                vc.viewModel.inputScreen = item
                vc.viewModel.delegate = self
                return vc
            }
        case .inputScreenG:
            if let vc = storyboard.instantiateViewController(withIdentifier: ScreenTypeGViewController.identifier) as? ScreenTypeGViewController {
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
            if let text = getSelectedText(for: item.id) {
                SpeechHelper.play(text: text, language: Locale.current.languageCode!)
            }
        }
    }
    
    func getBackground() -> String? {
        return inputScreen?.background?.url
    }
    
    func getBackgroundTransparency() -> Double? {
        return inputScreen?.backgroundTransparency
    }
}

extension ScreenTypeCViewModel: ScreenTypeCDelegate {
    func didSelect(value: Any, onScreen: InputScreen) {
        selectedItem.value[onScreen.id] = value
    }
}


