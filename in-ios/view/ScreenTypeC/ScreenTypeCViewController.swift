//
//  ScreenTypeCViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 02/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

protocol ScreenTypeCDelegate: class {
    func didSelect(value: Any, onScreen: InputScreen)
}

class ScreenTypeCViewController: BaseViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    let viewModel = ScreenTypeCViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.reloadCollectionView()
        }
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSpeakButtonClick(_ sender: Any) {
        viewModel.speakSelectedValues()
    }
    
    @IBAction func onClearButtonClick(_ sender: Any) {
        viewModel.selectedItem.value = [:]
        sendClearNotification()
    }
    
}

extension ScreenTypeCViewController {
    
    private func onViewLoad() {
        setupUI()
        loadViewModels()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupUI() {
        setupClearButton()
    }
    
    private func setupClearButton() {
        if let button = viewModel.getClearButton() {
            clearButton.isHidden = false
            if let urlString = button.icon?.url, let url = URL(string: urlString) {
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { [weak self] (image, error, cache, url) in
                    guard let `self` = self else { return }
                    self.clearButton.setImage(image, for: .normal)
                }
            }
        } else {
            clearButton.isHidden = true
        }
    }
    
    private func loadViewModels() {
        viewModel.loadItems()
        if viewModel.getItems().count > 0 {
            viewModel.selectedIndexPath.value = IndexPath(item: 0, section: 0)
        }
    }
    
    private func setupCollectionView() {
        mainCollectionView.register(UINib(nibName: ScreenTypeCMenuCollectionViewCell.identifier, bundle: nil),
                                    forCellWithReuseIdentifier: ScreenTypeCMenuCollectionViewCell.identifier)
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
    }
    
    private func setSubscribers() {
        viewModel.selectedItem.asObservable().subscribe(onNext: { (selectedItems) in
            self.reloadCollectionView()
        }).disposed(by: disposeBag)
        
        viewModel.items.asObservable().subscribe(onNext: { items in
            self.reloadCollectionView()
        }).disposed(by: disposeBag)
        
        viewModel.selectedIndexPath.asObservable().subscribe(onNext: { indexPath in
            guard let _ = indexPath else { return }
            self.reloadCollectionView()
            DispatchQueue.main.async {
                self.replaceViewController()
            }
        }).disposed(by: disposeBag)
    }
    
    private func reloadCollectionView() {
        DispatchQueue.main.async {
            self.mainCollectionView.collectionViewLayout.invalidateLayout()
            self.mainCollectionView.reloadData()
            self.view.layoutIfNeeded()
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
    
    private func sendClearNotification() {
        let userInfo = [NotificationKeys.UserInfo.ParentViewController: self]
        let notification = Notification(name: .ScreenTypeCClear, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}

// MARK: - UICollectionViewDataSource

extension ScreenTypeCViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ScreenTypeCMenuCollectionViewCell.identifier,
                                 for: indexPath) as? ScreenTypeCMenuCollectionViewCell else {
                fatalError("Cannot dequeue cell with reuseIdentifier: \(ScreenTypeCMenuCollectionViewCell.identifier)")
        }
        if let cellViewModel = viewModel.getItemViewModelFor(indexPath: indexPath) {
            cell.setViewModel(viewModel: cellViewModel)
        }
        if let selectedIndexPath = viewModel.selectedIndexPath.value {
            cell.setSelected(isSelected: indexPath == selectedIndexPath)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScreenTypeCViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.size.width / CGFloat(viewModel.getItems().count)
        let cellHeight = collectionView.bounds.size.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension ScreenTypeCViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndexPath.value = indexPath
    }
}
