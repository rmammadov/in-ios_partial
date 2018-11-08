//
//  ScreenTypeHViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 29/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeHViewModel: BaseViewModel {

    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    private var items = [ButtonInputScreen]()
    private var groupedItems: [[ButtonInputScreen]] = []
    private var page = Variable<Int>(0)
    private var selectedItem: ButtonInputScreen?
    private var selectedIndexPath: IndexPath?
    private var selectedLabels: [String] = []
    private var selectedTextToSpeech: [String] = []
    
    func loadItems() {
        guard let items = inputScreen?.buttons else { return }
        setItems(items)
    }
    
    func getItems() -> [ButtonInputScreen] {
        return items
    }
    
    func getSelectedItem() -> ButtonInputScreen? {
        return selectedItem
    }
    
    func setSelectedIndexPath(_ indexPath: IndexPath?) {
        self.selectedIndexPath = indexPath
    }
    
    func getSelectedIndexPath() -> IndexPath? {
        return selectedIndexPath
    }
    
    func setSelectedItem(_ item: ButtonInputScreen?) {
        self.selectedItem = item
    }
    
    func getCurrentPageItems() -> [ButtonInputScreen] {
        guard groupedItems.count > page.value else { return [] }
        return groupedItems[page.value]
    }
    
    func getPageObserver() -> Observable<Int> {
        return page.asObservable()
    }
    
    override func getRowCount() -> Int {
        if inputScreen.type != .inputScreenH {
            return super.getRowCount() - 1
        }
        return super.getRowCount()
    }
    
    private func setupGroupedItems() {
        let countItemsPerPage = (getRowCount() ) * (getColumnCount())
        var countItems = getItems().count
        
        if countItems <= countItemsPerPage {
            return groupedItems = [items]
        } else {
            var startingIndex: Int = 0
            
            while countItems > 0 {
                var countNavigationItems: Int = 1
                
                if groupedItems.count > 0 {
                    countNavigationItems = 2
                } else {
                    countNavigationItems = 1
                }
                
                countItems = countItems - (countItemsPerPage - countNavigationItems)
                var subItems: Array<ButtonInputScreen> = []
                if countItems > countNavigationItems {
                    subItems = Array(getItems()[startingIndex...startingIndex + countItemsPerPage - countNavigationItems - 1])
                    if groupedItems.count > 0 {  // If it is not first page add previous button also
                        subItems.append(getPreviousButton()!)
                    }
                    subItems.append(getNextButton()!) // Add next button
                    startingIndex = startingIndex + countItemsPerPage - countNavigationItems
                } else {
                    subItems = Array(getItems()[startingIndex...getItems().count - 1])
                    subItems.append(getPreviousButton()!) // Add previous button
                }
                
                groupedItems.append(subItems)
            }
        }
    }
    
    func getItemFor(indexPath: IndexPath) -> ButtonInputScreen {
        return groupedItems[page.value][indexPath.item]
    }
    
    private func setItems(_ items: [ButtonInputScreen]) {
        self.items = items
        setupGroupedItems()
    }
    
    func getPreviousButton() -> ButtonInputScreen? {
        return inputScreen?.previousButton
    }
    
    func getNextButton() -> ButtonInputScreen? {
        return inputScreen?.nextButton
    }
    
    func onItemLoadRequest(indexPath: IndexPath) -> ButtonInputScreen {
        let item = getItemFor(indexPath: indexPath)
        
        if !(item.disableTextToSpeech ?? true) {
            SpeechHelper.shared.play(translation: item.translations?.currentTranslation())
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.ALL_CLEAR else {
            clearSelectedValues()
            return item
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.EQUAL_SIGN else {
            calculateCurrentValue()
            return item
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.PREVIOUS_ITEM_NAME else {
            previousPage()
            return item
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.NEXT_ITEM_NAME else {
            nextPage()
            return item
        }
        
        guard item.type != .inputScreenOpen else {
            return item
        }
        selectedItem = item
        if let translation = item.translations?.currentTranslation() {
            selectedLabels.append(translation.label)
            selectedTextToSpeech.append(translation.labelTextToSpeech)
            var collectedLabel = ""
            var collectedTextToSpeech = ""
            selectedLabels.forEach { collectedLabel += $0 }
            selectedTextToSpeech.forEach { collectedTextToSpeech += $0 }
            let translation = Translation(locale: translation.locale,
                                          label: collectedLabel,
                                          textToSpeech: collectedTextToSpeech)
            delegate?.didSelect(value: translation, onScreen: inputScreen)
        }
        return item
    }
    
    func clearSelectedValues() {
        selectedLabels = []
        selectedTextToSpeech = []
        delegate?.didSelect(value: nil, onScreen: inputScreen)
    }
    
    private func calculateCurrentValue() {
        var expression = ""
        selectedLabels.forEach { expression.append($0) }
        expression = expression.lowercased().replacingOccurrences(of: "x", with: "*")
        expression = expression.replacingOccurrences(of: "÷", with: "/")
        do {
            let result = try expression.evaluate()
            var resultString = ""
            if result < Double(Int.max) {
                resultString = result == Double(Int(result)) ? String(format: "%.0lf", result) : String(result)
            } else {
                resultString = String(result)
            }
            
            let translationItem = Translation(locale: selectedItem?.translations?.currentTranslation()?.locale ?? "en",
                                              label: resultString,
                                              textToSpeech: resultString)
            selectedLabels = [resultString]
            selectedTextToSpeech = [resultString]
            delegate?.didSelect(value: translationItem, onScreen: inputScreen)
            SpeechHelper.shared.play(translation: translationItem)
        } catch let error {
            print("Error: calculateCurrentValue: \(error.localizedDescription)")
            return
        }
    }
    
    func prepareViewControllerFor(item: ButtonInputScreen) -> UIViewController? {
        guard
            let inputScreenId = item.inputScreenId, item.type == .inputScreenOpen,
            let inputScreen = DataManager.getInputScreens().getInputScreenFor(id: inputScreenId),
            let viewController = UIViewController.instantiateViewController(for: inputScreen.type)
            else { return nil }
        switch inputScreen.type {
        case .inputScreenA,
             .inputScreenB:
            guard let vc = viewController as? InputAViewController else { return nil }
            vc.viewModel.inputScreen = inputScreen
            return vc
        case .inputScreenC:
            guard let vc = viewController as? ScreenTypeCViewController else { return nil }
            vc.viewModel.inputScreen = inputScreen
            return vc
        default:
            return nil
        }
    }
    
    func nextPage() {
        guard groupedItems.count > page.value + 1 else { return }
        page.value += 1
    }
    
    func previousPage() {
        guard 0 <= page.value - 1 else { return }
        page.value -= 1
    }
}
