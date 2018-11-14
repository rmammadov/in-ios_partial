//
//  ScreenTypeEViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 04/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeEViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var isDisappear: Bool = true
    let viewModel = ScreenTypeEViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerGazeTrackerObserver()
        isDisappear = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterGazeTrackerObserver()
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

extension ScreenTypeEViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupCollectionView() {
        let cellNib = UINib(nibName: cellNibName, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setSubscribers() {
        viewModel.getPageObserver().subscribe(onNext: { (_) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        AnimationUtil.status.asObservable().subscribe(onNext: { (status) in
            guard !self.isDisappear else { return }
            guard
                status == AnimationStatus.completed.rawValue,
                AnimationUtil.getTag() == ScreenTypeEViewController.identifier,
                let indexPath = self.viewModel.getSelectedIndexPath(),
                let cell = self.collectionView.cellForItem(at: indexPath) as? AnimateObject
                else { return }
            self.viewModel.setSelection(nil)
            AnimationUtil.cancelAnimation(object: cell)
            let item = self.viewModel.onItemLoadRequest(indexPath: indexPath)
            if item.type == .inputScreenOpen, let nextVC = self.viewModel.prepareViewControllerFor(item: item) {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension ScreenTypeEViewController: UICollectionViewDataSource {
    var cellNibName: String {
        switch viewModel.inputScreen.type {
        case .inputScreenH:
            return ScreenTypeHCollectionViewCell.identifier
        default:
            return "MenuItemCollectionViewCell"
        }
    }
    var cellIdentifier: String {
        switch viewModel.inputScreen.type {
        case .inputScreenH:
            return ScreenTypeHCollectionViewCell.identifier
        default:
            return "cellMenuItem"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCurrentPageItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.inputScreen.type {
        case .inputScreenH:
            return prepareScreenTypeHCell(collectionView: collectionView, indexPath: indexPath)
        default:
            return prepareStandardItemCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    private func prepareScreenTypeHCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? ScreenTypeHCollectionViewCell else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(cellIdentifier)")
        }
        let item = viewModel.getItemFor(indexPath: indexPath)
        cell.setCell(url: item.icon?.url)
        return cell
    }
    
    private func prepareStandardItemCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? MenuItemCollectionViewCell else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(cellIdentifier)")
        }
        let item = viewModel.getItemFor(indexPath: indexPath)
        cell.setCell(url: item.icon?.url, label: item.translations?.currentTranslation()?.label)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ScreenTypeEViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ItemUtil.shared.getItemSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCellAt(indexPath: indexPath, fingerTouch: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScreenTypeEViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let itemSize = ItemUtil.shared.getItemSize()
        return (collectionView.bounds.width - (CGFloat(viewModel.getColumnCount()) * itemSize.width)) / CGFloat(viewModel.getColumnCount() - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let itemSize = ItemUtil.shared.getItemSize()
        return (collectionView.bounds.height - (CGFloat(viewModel.getRowCount()) * itemSize.height)) / CGFloat(viewModel.getRowCount() - 1)
    }
}

// MARK: - GazeTrackerUpdateProtocol

extension ScreenTypeEViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        guard let mainView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let newPoint = mainView.convert(coordinate, to: self.collectionView)
        selectCellAt(indexPath: self.collectionView.indexPathForItem(at: newPoint))
    }
    
    private func selectCellAt(indexPath: IndexPath?, fingerTouch: Bool = false) {
        guard viewModel.getSelection() != indexPath else { return }
        if let lastSelectionIndexPath = viewModel.getSelection(),
            let lastCell = collectionView.cellForItem(at: lastSelectionIndexPath) as? AnimateObject {
            AnimationUtil.cancelAnimation(object: lastCell)
        }
        viewModel.setSelection(indexPath)
        guard let indexPath = indexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? AnimateObject else { return }
        viewModel.setSelectedIndexPath(indexPath)
        AnimationUtil.animateSelection(object: cell, fingerTouch: fingerTouch, tag: ScreenTypeEViewController.identifier)
    }
}
