//
//  ScreenTypeHViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 29/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeHViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let  kMarginBetweenItems: CGFloat = 24
    private var isDisappear: Bool = true
    let viewModel = ScreenTypeHViewModel()
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

extension ScreenTypeHViewController {
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
                AnimationUtil.getTag() == ScreenTypeHViewController.identifier,
                let indexPath = self.viewModel.getSelectedIndexPath(),
                let cell = self.collectionView.cellForItem(at: indexPath) as? AnimateObject
                else { return }
            AnimationUtil.cancelAnimation(object: cell)
            let item = self.viewModel.onItemLoadRequest(indexPath: indexPath)
            if item.type == .inputScreenOpen, let nextVC = self.viewModel.prepareViewControllerFor(item: item) {
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension ScreenTypeHViewController: UICollectionViewDataSource {
    var cellNibName: String {
        return ScreenTypeHCollectionViewCell.identifier
    }
    
    var cellIdentifier: String {
        return ScreenTypeHCollectionViewCell.identifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCurrentPageItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return prepareScreenTypeHCell(collectionView: collectionView, indexPath: indexPath)
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
}

// MARK: - UICollectionViewDelegate

extension ScreenTypeHViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginSpace = CGFloat(viewModel.getItemMargin() * (viewModel.getRowCount() - 1))
        var cellWidth = (self.collectionView.frame.size.width - marginSpace) / CGFloat(viewModel.getColumnCount())
        let cellHeight = (self.collectionView.frame.size.height / CGFloat(viewModel.getRowCount())) - kMarginBetweenItems
        if cellWidth > cellHeight {
            cellWidth = cellHeight
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AnimateObject
            else { return }
        viewModel.setSelectedIndexPath(indexPath)
        AnimationUtil.animateSelection(object: cell, fingerTouch: true, tag: ScreenTypeHViewController.identifier)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScreenTypeHViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let marginSpace = CGFloat(viewModel.getItemMargin() * (viewModel.getRowCount() - 1))
        var cellWidth = (self.collectionView.frame.size.width - marginSpace) / CGFloat(viewModel.getColumnCount())
        let cellHeight = (self.collectionView.frame.size.height / CGFloat(viewModel.getRowCount())) - kMarginBetweenItems
        if cellWidth > cellHeight {
            cellWidth = cellHeight
            return (collectionView.frame.width - (CGFloat(viewModel.getColumnCount()) * cellWidth)) / CGFloat(viewModel.getColumnCount() - 1)
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kMarginBetweenItems
    }
}
