//
//  ScreenTypeDViewModel.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

protocol ScreenTypeDDelegate: class {
    func didSelect(value: Any, onButton button: ButtonInputScreen)
}

class ScreenTypeDViewModel: BaseViewModel {
    
    weak var delegate: ScreenTypeCDelegate?
    var inputScreen: InputScreen!
    
    private var items: [ButtonInputScreen] = []
    private var viewControllers: [UIViewController] = []
    private var selectedIndexPath = Variable<IndexPath?>(nil)
    private var selectionIndexPath: IndexPath?
    
    func loadItems() {
        guard let items = inputScreen.buttons, items.count > 0 else { return }
        self.items = items
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vcs: [UIViewController] = []
        items.forEach({ (button) in
            if let vc = storyboard.instantiateViewController(withIdentifier: BodyPartViewController.identifier) as? BodyPartViewController {
                vc.viewModel.button = button
                vc.viewModel.delegate = self
                vcs.append(vc)
            }
        })
        selectedIndexPath.value = IndexPath(item: 0, section: 0)
        self.viewControllers = vcs
    }
    
    func getSelectedViewController() -> UIViewController? {
        guard let index = getSelectedIndexPath()?.item, viewControllers.count > index else { return nil }
        return viewControllers[index]
    }
    
    func setSelectedIndexPath(_ indexPath: IndexPath?) {
        selectedIndexPath.value = indexPath
    }
    
    func getItems() -> [ButtonInputScreen] {
        return items
    }
    
    func getItem(for indexPath: IndexPath) -> ButtonInputScreen? {
        guard indexPath.item < items.count else { return nil }
        return items[indexPath.item]
    }
    
    func getSelectedIndexPath() -> IndexPath? {
        return selectedIndexPath.value
    }
    
    func getSelectedIndexPathObserver() -> Observable<IndexPath?> {
        return selectedIndexPath.asObservable()
    }
    
    func getSelection() -> IndexPath? {
        return selectionIndexPath
    }
    
    func setSelection(_ indexPath: IndexPath?) {
        selectionIndexPath = indexPath
    }
}

extension ScreenTypeDViewModel: ScreenTypeDDelegate {
    func didSelect(value: Any, onButton button: ButtonInputScreen) {
        delegate?.didSelect(value: value, onScreen: inputScreen)
        viewControllers.forEach { (viewController) in
            guard let viewController = viewController as? BodyPartViewController,
                viewController.viewModel.button.translations?.currentTranslation()?.label != button.translations?.currentTranslation()?.label
                else { return }
            viewController.viewModel.selectedBubble = nil
        }
    }
}
