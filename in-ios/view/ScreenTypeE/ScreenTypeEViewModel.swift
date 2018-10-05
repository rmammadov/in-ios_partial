//
//  ScreenTypeEViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 04/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import Foundation
import RxSwift

class ScreenTypeEViewModel: BaseViewModel {
    
    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    private var items = [ButtonInputScreen]()
    private var groupedItems: [[ButtonInputScreen]] = []
    private var page = Variable<Int>(0)
    private var selectedItem: ButtonInputScreen?
    private var selectedIndexPath: IndexPath?
    
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
        return super.getRowCount() - 1
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
    
    func loadItems() {
        guard let items = inputScreen?.buttons else { return }
        setItems(items)
    }
    
    func onItemLoadRequest(indexPath: IndexPath) {
        let item = getItemFor(indexPath: indexPath)
        
        if !(item.disableTextToSpeech ?? true), let text = item.translations?.first?.labelTextToSpeech {
            SpeechHelper.play(text: text, language: "en-US")
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.PREVIOUS_ITEM_NAME else {
            previousPage()
            return
        }
        
        guard item.translations?.first?.label != Constant.MenuConfig.NEXT_ITEM_NAME else {
            nextPage()
            return
        }
        selectedItem = item
        
        delegate?.didSelect(button: item, onScreen: self.inputScreen)
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