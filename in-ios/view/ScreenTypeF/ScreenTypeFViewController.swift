//
//  ScreenTypeFViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 05/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeFViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isDisappear: Bool = true
    let viewModel = ScreenTypeFViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisappear = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappear = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }

}

extension ScreenTypeFViewController {
    var cellIdentifier: String {
        return ColoredButtonCollectionViewCell.identifier
    }
    private func onViewLoad() {
        registerObservers()
        viewModel.loadItems()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
    }
}

// MARK: - UICollectionViewDataSource

extension ScreenTypeFViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? ColoredButtonCollectionViewCell else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(cellIdentifier)")
        }
        let item = viewModel.getItems()[indexPath.row]
        guard item.type == .colored,
            let mainColor = item.mainColor,
            let gradientColor = item.gradientColor,
            let translations = item.translations
            else { return cell }
        let cellViewModel = ColoredButtonCollectionViewCell.ViewModel(mainColor: mainColor, gradientColor: gradientColor, translations: translations)
        cell.setViewModel(cellViewModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ScreenTypeFViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2.0
        let numberOfLines = viewModel.getItems().count / 2 + viewModel.getItems().count % 2
        var cellHeight = collectionView.frame.height / CGFloat(numberOfLines)
        if cellHeight > 140.0 {
            cellHeight = 140.0
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColoredButtonCollectionViewCell
            else { return }
        viewModel.setSelected(indexPath: indexPath)
        cell.setSelected(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColoredButtonCollectionViewCell
            else { return }
        cell.setSelected(false)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScreenTypeFViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
    }
}

extension ScreenTypeFViewController {
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onParentClearSelection(notification:)),
                                               name: Notification.Name.ScreenTypeCClear, object: nil)
    }
    
    @objc func onParentClearSelection(notification: Notification) {
        guard let indexPath = viewModel.getSelectedIndexPath() else { return }
        viewModel.setSelected(indexPath: nil)
        if let cell = collectionView.cellForItem(at: indexPath) as? ColoredButtonCollectionViewCell {
            cell.setSelected(false)
        }
    }
}
