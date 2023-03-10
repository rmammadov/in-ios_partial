//
//  InputViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"

class InputAViewController: BaseViewController {

    private static let TAG = "InputAViewController"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnBack: GradientButton!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakButtonTrailingConstraint: NSLayoutConstraint!
    private var isDisappear: Bool = true
    
    let viewModel = InputAViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUi()
        
        setLastState(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setSelection(indexPath: nil)
        isDisappear = false
        registerGazeTrackerObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        onOrientationChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterGazeTrackerObserver()
        cancelLastSelection()
        viewModel.selectionButton = nil
        viewModel.setSelection(indexPath: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisappear = true
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSpeakBtn(_ sender: Any) {
    }
}

extension InputAViewController {
    
    func getParentViewController() -> HomeViewController {
        return self.parent?.parent?.parent as! HomeViewController
    }
    
    func setUi() {
        self.setViewModel()
        self.setTitle()
        self.setBackground()
        self.setBackButtonStatus()
        self.setSpeakButtonStatus()
        self.setCollectionView()
        self.setSubscribers()
    }
    
    func updateUi() {
        collectionView.reloadData()
    }
    
    func setViewModel() {
        self.viewModel.loadScreen()
        self.viewModel.setParentVC(vc: self.getParentViewController())
    }
    
    func setTitle() {
        self.labelTitle.text = self.viewModel.getTitle()
    }
    
    func setBackground() {
        getParentViewController().viewModel.setBackgroundImage(url: viewModel.getBackground())
        getParentViewController().viewModel.setBackgroundTransparency(transparency: viewModel.getBackgroundTransparency())
    }
    
    func setBackButtonStatus() {
        if !self.viewModel.getBackButtonStatus()! {
            btnBack.isHidden = !self.viewModel.getBackButtonStatus()!
            backButtonLeadingConstraint.constant = backButtonLeadingConstraint.constant - btnBack.frame.width
        }
    }
    
    func setSpeakButtonStatus() {
        if !self.viewModel.getSpeakButtonStatus()! {
            btnSpeak.isHidden = !self.viewModel.getSpeakButtonStatus()!
            speakButtonTrailingConstraint.constant = speakButtonTrailingConstraint.constant + btnSpeak.frame.width
        }
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib.init(nibName: nibMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {[weak self] event in
            guard let `self` = self else { return }
            if self.viewModel.status.value == InputAStatus.loaded.rawValue {
                DispatchQueue.main.async {
                    guard let indexPath = self.viewModel.getSelection(),
                        let cell = self.getCellForIndexPath(indexPath: indexPath)
                        else { return }
                    self.updateUi()
                }
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.statusInput.asObservable().subscribe(onNext: { [weak self] (inputStatus) in
            guard let `self` = self else { return }
            if inputStatus == InputScreenId.inputScreen0.rawValue {
                DispatchQueue.main.async {
                    guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "InputAViewController")
                        as? InputAViewController,
                    let inputScreen = self.viewModel.loadInputScreenItem() else {
                        return
                    }
                    nextVC.viewModel.inputScreen = inputScreen
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            } else if inputStatus == InputScreenId.inputScreen1.rawValue {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let screenCVC = storyboard.instantiateViewController(withIdentifier: "ScreenTypeCViewController") as? ScreenTypeCViewController,
                    let inputScreen = self.viewModel.loadInputScreenItem()
                    else { return }
                screenCVC.viewModel.setInputScreen(inputScreen)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(screenCVC, animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            guard !self.isDisappear else { return }
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue {
                if AnimationUtil.getTag() == InputAViewController.TAG {
                    guard let indexPath = self.viewModel.getSelection(),
                        let cell = self.getCellForIndexPath(indexPath: indexPath) else { return }
                    cell.cancelAnimation()
                    cell.setSelected(true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        cell.setSelected(false)
                        self.viewModel.onItemLoadRequest(indexPath: indexPath)
                    })
                } else if AnimationUtil.getTag() == "InputA.BackButton" {
                    self.viewModel.selectionButton = nil
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
    }
}

extension InputAViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    // FIXME: Fix the hardcode and update collection data properly
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getGroupedItems()[viewModel.getPage()].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuItemCollectionViewCell
        
        self.viewModel.setItem(index: indexPath.row)
        cell.setCell(url: self.viewModel.getItemIcon(), label: self.viewModel.getItemTitle())
        
        return cell
    }
    
    // FIXME: Remove the hardcode
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ItemUtil.shared.getItemSize()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let itemUtil = ItemUtil.shared
        let itemSize = itemUtil.getItemSize()
        return (collectionView.bounds.width - (CGFloat(itemUtil.getColumnCount()) * itemSize.width)) / CGFloat(itemUtil.getColumnCount() - 1)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCellAt(indexPath: indexPath, fingerTouch: true)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> MenuItemCollectionViewCell? {
        guard let cell: MenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as? MenuItemCollectionViewCell else { return nil}
        
        return cell
    }

    func onOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
}

extension InputAViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        guard let mainView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let newPoint = mainView.convert(coordinate, to: self.collectionView)
        let viewPoint = mainView.convert(coordinate, to: self.view)
        selectCellAt(indexPath: self.collectionView.indexPathForItem(at: newPoint))
        selectBackButton(isSelected: btnBack.frame.contains(viewPoint))
    }
    
    private func selectCellAt(indexPath: IndexPath?, fingerTouch: Bool = false) {
        guard indexPath != self.viewModel.getSelection() else { return }
        cancelLastSelection()
        self.viewModel.setSelection(indexPath: indexPath)
        guard let indexPath = indexPath, let cell = self.getCellForIndexPath(indexPath: indexPath) else { return }
        AnimationUtil.animateSelection(object: cell, fingerTouch: fingerTouch, tag: InputAViewController.TAG)
        if let homeVC = self.parent?.parent?.parent as? HomeViewController {
            homeVC.viewModel.setMenuExpanded(false)
        }
    }
    
    private func selectBackButton(isSelected: Bool, fingerTouch: Bool = false) {
        if isSelected {
            if viewModel.selectionButton != btnBack {
                AnimationUtil.animateSelection(object: btnBack, fingerTouch: fingerTouch, tag: "InputA.BackButton")
            }
        } else {
            AnimationUtil.cancelAnimation(object: btnBack)
        }
        viewModel.selectionButton = isSelected ? btnBack : nil
    }
    
    private func cancelLastSelection() {
        if let lastIndexPath = self.viewModel.getSelection(),
            let cell = collectionView.cellForItem(at: lastIndexPath) as? AnimateObject {
            AnimationUtil.cancelAnimation(object: cell)
        }
        if let object = viewModel.selectionButton as? AnimateObject {
            AnimationUtil.cancelAnimation(object: object)
        }
    }
}

