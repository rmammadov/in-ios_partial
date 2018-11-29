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
    func didSelect(value: Any?, onScreen: InputScreen)
}

class ScreenTypeCViewController: BaseViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var clearButton: GradientButton!
    @IBOutlet weak var speakButton: GradientButton!
    @IBOutlet weak var backButton: GradientButton!
    @IBOutlet weak var containerView: UIView!
    
    let viewModel = ScreenTypeCViewModel()
    private var isDisappear: Bool = true
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisappear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerGazeTrackerObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelLastSelection()
        viewModel.selectionButton = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappear = true
        unregisterGazeTrackerObserver()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.reloadCollectionView()
        }
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        selectBackButton(isSelected: true, fingerTouch: true)
    }
    
    @IBAction func onSpeakButtonClick(_ sender: Any) {
        selectSpeakButton(isSelected: true, fingerTouch: true)
    }
    
    @IBAction func onClearButtonClick(_ sender: Any) {
        selectClearButton(isSelected: true, fingerTouch: true)
    }
    
    private func clear() {
        viewModel.selectedItem.value = [:]
        sendClearNotification()
        let itemType = "ClearButton"
        let tileContext = viewModel.inputScreen?.translations.currentTranslation()?.label ?? ""
        let locale = SettingsHelper.shared.language.rawValue
        DatabaseWorker.shared.addUsage(locale: locale, label: itemType, itemType: itemType, itemId: 0, tileContext: tileContext)
    }
    
    private func speak() {
        if SettingsHelper.shared.isSoundEnabled {
            viewModel.speakSelectedValues()
        } else {
            displaySoundDisabledAlert()
        }
        let itemType = "SpeakButton"
        let tileContext = viewModel.inputScreen?.translations.currentTranslation()?.label ?? ""
        let locale = SettingsHelper.shared.language.rawValue
        DatabaseWorker.shared.addUsage(locale: locale, label: itemType, itemType: itemType, itemId: 0, tileContext: tileContext)
    }
    
    private func displaySoundDisabledAlert() {
        let alert = UIAlertController(title: "warning".localized, message: "soundDisabledInfo".localized, preferredStyle: .alert)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                alert.dismiss(animated: true)
            })
        }
    }
    
    private func back() {
        navigationController?.popViewController(animated: true)
        let itemType = "BackButton"
        let tileContext = viewModel.inputScreen?.translations.currentTranslation()?.label ?? ""
        let locale = SettingsHelper.shared.language.rawValue
        DatabaseWorker.shared.addUsage(locale: locale, label: itemType, itemType: itemType, itemId: 0, tileContext: tileContext)
    }
}

extension ScreenTypeCViewController {
    
    
    func getParentViewController() -> HomeViewController? {
        return self.parent?.parent?.parent as? HomeViewController
    }
    
    private func onViewLoad() {
        setupUI()
        loadViewModels()
        setupCollectionView()
        setSubscribers()
    }
    
    private func setupUI() {
        setupClearButton()
        setBackground()
    }
    
    func setBackground() {
        if let parentVC = getParentViewController() {
            parentVC.viewModel.setBackgroundImage(url: viewModel.getBackground())
            parentVC.viewModel.setBackgroundTransparency(transparency: viewModel.getBackgroundTransparency())
        }
    }
    
    private func setupClearButton() {
        if let button = viewModel.getClearButton() {
            clearButton.isHidden = false
            if let urlString = button.icon?.url, let url = URL(string: urlString) {
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { [weak self] (image, error, cache, url) in
                    guard let `self` = self else { return }
                    self.clearButton.setImage(image, for: .normal)
                    self.clearButton.setNeedsDisplay()
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
        
        AnimationUtil.status.asObservable().subscribe(onNext: { [weak self] (status) in
            guard let `self` = self, !self.isDisappear, status == AnimationStatus.completed.rawValue else { return }
            switch AnimationUtil.getTag() {
            case "STC.BackButtonTag":
                self.back()
            case "STC.SpeakButtonTag":
                self.speak()
            case "STC.ClearButtonTag":
                self.clear()
            default:
                break
            }
            self.viewModel.selectionButton = nil
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

extension ScreenTypeCViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        guard let mainView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let collectionViewPoint = mainView.convert(coordinate, to: mainCollectionView)
        if let indexPath = mainCollectionView.indexPathForItem(at: collectionViewPoint) {
            viewModel.selectedIndexPath.value = indexPath
        }
        let backPoint = mainView.convert(coordinate, to: backButton)
        let speakPoint = mainView.convert(coordinate, to: speakButton)
        let clearPoint = mainView.convert(coordinate, to: clearButton)
        
        if backButton.bounds.contains(backPoint) {
            selectBackButton(isSelected: true)
        } else if speakButton.bounds.contains(speakPoint) {
            selectSpeakButton(isSelected: true)
        } else if clearButton.bounds.contains(clearPoint) {
            selectSpeakButton(isSelected: true)
        } else {
            if let selectionButton = viewModel.selectionButton {
                switch selectionButton {
                case backButton:
                    selectBackButton(isSelected: false)
                case speakButton:
                    selectSpeakButton(isSelected: false)
                case clearButton:
                    selectClearButton(isSelected: false)
                default: return
                }
            }
        }
    }
    
    func selectBackButton(isSelected: Bool, fingerTouch: Bool = false) {
        if isSelected {
            if viewModel.selectionButton != backButton {
                AnimationUtil.animateSelection(object: backButton, fingerTouch: fingerTouch, tag: "STC.BackButtonTag")
            }
        } else {
            AnimationUtil.cancelAnimation(object: backButton)
        }
        viewModel.selectionButton = isSelected ? backButton : nil
    }
    
    func selectSpeakButton(isSelected: Bool, fingerTouch: Bool = false) {
        if isSelected {
            if viewModel.selectionButton != speakButton {
                AnimationUtil.animateSelection(object: speakButton, fingerTouch: fingerTouch, tag: "STC.SpeakButtonTag")
            }
        } else {
            AnimationUtil.cancelAnimation(object: speakButton)
        }
        viewModel.selectionButton = isSelected ? speakButton : nil
    }
    
    func selectClearButton(isSelected: Bool, fingerTouch: Bool = false) {
        if isSelected {
            if viewModel.selectionButton != speakButton {
                AnimationUtil.animateSelection(object: clearButton, fingerTouch: fingerTouch, tag: "STC.ClearButtonTag")
            }
        } else {
            AnimationUtil.cancelAnimation(object: clearButton)
        }
        viewModel.selectionButton = isSelected ? clearButton : nil
    }
    
    private func cancelLastSelection() {
        if let object = viewModel.selectionButton as? AnimateObject {
            AnimationUtil.cancelAnimation(object: object)
        }
    }
}
