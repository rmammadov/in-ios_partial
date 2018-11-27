//
//  ScreenTypeGViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 22/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeGViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isDisappear: Bool = true
    let viewModel = ScreenTypeGViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisappear = false
        registerGazeTrackerObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelLastSelection()
        viewModel.setSelection(nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappear = true
        unregisterGazeTrackerObserver()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
}

extension ScreenTypeGViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setSubscribers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onParentClearSelection(notification:)),
                                               name: Notification.Name.ScreenTypeCClear, object: nil)
        AnimationUtil.status.asObservable().subscribe(onNext: { [weak self] (status) in
            guard let `self` = self,
                status == AnimationStatus.completed.rawValue,
                AnimationUtil.getTag() == self.tag
                else { return }
            if let lastSelectedIndex = self.viewModel.selectedIndex,
                let cell = self.collectionView.cellForItem(at: lastSelectedIndex) as? ScreenTypeGCollectionViewCell {
                cell.setSelected(false)
            }
            self.viewModel.selectedIndex = self.viewModel.newSelectedIndex
            if let selectedIndex = self.viewModel.newSelectedIndex, let cell = self.collectionView.cellForItem(at: selectedIndex) as? ScreenTypeGCollectionViewCell {
                cell.setSelected(true)
            }
            self.viewModel.onSelectionComplete()
        }).disposed(by: disposeBag)
    }
}

extension ScreenTypeGViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    var cellIdentifier: String {
        return ScreenTypeGCollectionViewCell.identifier
    }
    
    var tag: String {
        return "\(cellIdentifier).\(self)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel.getItemAt(indexPath: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ScreenTypeGCollectionViewCell
            else { fatalError("Cannot dequeue cell with identifier: \(cellIdentifier)") }
        guard let translations = item.translations
            else { fatalError("Cannot get translations from \(item)") }
        let cellViewModel = ScreenTypeGCollectionViewCell.ViewModel(translations: translations)
        cell.viewModel = cellViewModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCellAt(indexPath: indexPath, fingerTouch: true)
    }
}

extension ScreenTypeGViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width / 3
        let height: CGFloat = 110
        return CGSize(width: width, height: height)
    }
}

extension ScreenTypeGViewController {
    @objc func onParentClearSelection(notification: Notification) {
        guard let indexPath = viewModel.selectedIndex else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? ScreenTypeGCollectionViewCell {
            cell.setSelected(false)
        }
    }
}

// MARK: - GazeTrackerUpdateProtocol

extension ScreenTypeGViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        guard let mainView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let newPoint = mainView.convert(coordinate, to: self.collectionView)
        selectCellAt(indexPath: self.collectionView.indexPathForItem(at: newPoint))
    }
    
    private func selectCellAt(indexPath: IndexPath?, fingerTouch: Bool = false) {
        guard viewModel.getSelection() != indexPath else { return }
        cancelLastSelection()
        viewModel.setSelection(indexPath)
        guard let indexPath = indexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? ScreenTypeGCollectionViewCell,
            viewModel.selectedIndex != indexPath
            else { return }
        viewModel.newSelectedIndex = indexPath
        AnimationUtil.animateSelection(object: cell, fingerTouch: fingerTouch, tag: tag)
    }
    
    private func cancelLastSelection() {
        guard let lastSelectionIndexPath = viewModel.getSelection(),
            let lastCell = collectionView.cellForItem(at: lastSelectionIndexPath) as? AnimateObject
            else { return }
        AnimationUtil.cancelAnimation(object: lastCell)
    }
}
