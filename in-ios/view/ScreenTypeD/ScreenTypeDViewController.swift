//
//  ScreenTypeDViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 08/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"

class ScreenTypeDViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
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
        let cellNib = UINib(nibName: nibMenuItem, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setSubscribers() {
        viewModel.getSelectedIndexPathObserver().subscribe(onNext: { [weak self] (indexPath) in
            guard indexPath != nil else { return }
            self?.replaceViewController()
        }).disposed(by: disposeBag)
    }
}

extension ScreenTypeDViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                            for: indexPath) as? MenuItemCollectionViewCell,
        let item = viewModel.getItem(for: indexPath)
            else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(reuseIdentifier)")
        }
        cell.setCell(url: item.icon?.url, label: item.translations?.first?.label)
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
        let width = collectionView.bounds.size.width
        var height: CGFloat = 0
        if view.bounds.height / CGFloat(viewModel.getRowCount() - 1) > width + 7.0 + 7.0 + 17.0 {
            height = width + 7.0 + 7.0 + 17.0
        } else {
            height = view.bounds.height / CGFloat(viewModel.getRowCount() - 1)
        }
        collectionViewHeight.constant = height * CGFloat(viewModel.getItems().count)
        return CGSize(width: width, height: height)
    }
}
