//
//  ScreenTypeDViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeDViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    private var itemsWidth: [CGFloat] = [] {
        didSet {
            guard itemsWidth.count > 0 else { return }
            var width: CGFloat = 0
            itemsWidth.forEach { width += $0 }
            collectionViewWidth.constant = width
        }
    }
    
    private var isDisappear: Bool = true
    let viewModel = ScreenTypeDViewModel()
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
    
    private func replaceViewController() {
        guard let nextVC = viewModel.getSelectedViewController() else { return }
        if let childVC = children.first {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        addChild(nextVC)
        containerView.addSubview(nextVC.view)
        nextVC.view.frame = containerView.bounds
        nextVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nextVC.didMove(toParent: self)
    }

}

extension ScreenTypeDViewController {
    private func onViewLoad() {
        viewModel.loadItems()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupCollectionView() {
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setSubscribers() {
        viewModel.getSelectedIndexPathObserver().subscribe(onNext: { [weak self] (indexPath) in
            self?.collectionView.visibleCells.forEach({ (cell) in
                guard let cell = cell as? ScreenTypeDCollectionViewCell else { return }
                if indexPath != nil, self?.collectionView.indexPath(for: cell) == indexPath {
                    cell.setSelected(true)
                } else {
                    cell.setSelected(false)
                }
            })
            guard indexPath != nil else { return }
            self?.replaceViewController()
        }).disposed(by: disposeBag)
    }
}

extension ScreenTypeDViewController: UICollectionViewDataSource {
    var cellIdentifier: String {
        return ScreenTypeDCollectionViewCell.identifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.getItems().count
        itemsWidth = Array(repeating: 0.0, count: count)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? ScreenTypeDCollectionViewCell,
        let item = viewModel.getItem(for: indexPath)
            else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(cellIdentifier)")
        }
        cell.setSelected(indexPath == viewModel.getSelectedIndexPath())
        cell.setTitle(title: item.translations?.first?.label ?? "")
        return cell
    }
}

extension ScreenTypeDViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setSelectedIndexPath(indexPath)
    }
    
}

extension ScreenTypeDViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = viewModel.getItem(for: indexPath)?.translations?.first?.label ?? ""
        let width: CGFloat = ScreenTypeDCollectionViewCell.cellWidth(forText: text)
        let height: CGFloat = collectionView.bounds.height
        itemsWidth[indexPath.item] = width
        return CGSize(width: width, height: height)
    }
}
