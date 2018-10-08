//
//  ScreenTypeEViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 04/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"

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

extension ScreenTypeEViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupCollectionView() {
        let cellNib = UINib(nibName: nibMenuItem, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
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
                let cell = self.collectionView.cellForItem(at: indexPath) as? MenuItemCollectionViewCell
                else { return }
            AnimationUtil.cancelMenuSelection(imageView: cell.ivStatusIcon)
            self.viewModel.onItemLoadRequest(indexPath: indexPath)
        }).disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource

extension ScreenTypeEViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getCurrentPageItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            as? MenuItemCollectionViewCell else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(reuseIdentifier)")
        }
        let item = viewModel.getItemFor(indexPath: indexPath)
        cell.setCell(url: item.icon?.url, label: item.translations?.first?.label)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ScreenTypeEViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginSpace = CGFloat(viewModel.getItemMargin() * (viewModel.getRowCount() - 1))
        var cellWidth = (self.collectionView.frame.size.width - marginSpace) / CGFloat(viewModel.getColumnCount())
        let cellHeight = self.collectionView.frame.size.height / CGFloat(viewModel.getRowCount())
        if cellWidth > cellHeight {
            cellWidth = cellHeight - (7.0 + 7.0 + 17.0)
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MenuItemCollectionViewCell
            else { return }
        viewModel.setSelectedIndexPath(indexPath)
        AnimationUtil.animateMenuSelection(imageView: cell.ivStatusIcon, fingerTouch: true, tag: ScreenTypeEViewController.identifier)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScreenTypeEViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let marginSpace = CGFloat(viewModel.getItemMargin() * (viewModel.getRowCount() - 1))
        var cellWidth = (self.collectionView.frame.size.width - marginSpace) / CGFloat(viewModel.getColumnCount())
        let cellHeight = self.collectionView.frame.size.height / CGFloat(viewModel.getRowCount())
        if cellWidth > cellHeight {
            cellWidth = cellHeight - (7.0 + 7.0 + 17.0)
            return (collectionView.frame.width - (CGFloat(viewModel.getColumnCount()) * cellWidth)) / CGFloat(viewModel.getColumnCount() - 1)
        } else {
            return 0
        }
    }
}
