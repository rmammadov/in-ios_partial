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

class ScreenTypeCViewController: BaseViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var mainCollectionViewWidth: NSLayoutConstraint!
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
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSpeakButtonClick(_ sender: Any) {
        
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
            self.mainCollectionView.reloadData()
            var width: CGFloat = 0
            for i in 0..<self.viewModel.getItems().count {
                let indexPath = IndexPath(item: i, section: 0)
                if let cellWidth = self.viewModel.getItemViewModelFor(indexPath: indexPath)?.widthForCell {
                    width += cellWidth
                }
            }
            self.mainCollectionViewWidth.constant = width
            self.view.layoutIfNeeded()
        }
    }
    
    private func replaceViewController() {
        guard let nextVC = viewModel.getSelectedViewController()
            else { return }
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
        guard let cellViewModel = viewModel.getItemViewModelFor(indexPath: indexPath)
            else { return .zero }
        return CGSize(width: cellViewModel.widthForCell, height: collectionView.frame.height)
    }
}

extension ScreenTypeCViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndexPath.value = indexPath
    }
}
