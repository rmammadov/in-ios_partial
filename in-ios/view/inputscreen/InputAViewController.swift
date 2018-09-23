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
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakButtonTrailingConstraint: NSLayoutConstraint!
    
    let viewModel = InputAViewModel()
    let disposeBag = DisposeBag()

    var page = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
    }
    
    deinit {}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        onOrientationChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            btnBack.isHidden = self.viewModel.getBackButtonStatus()!
            backButtonLeadingConstraint.constant = backButtonLeadingConstraint.constant - btnBack.frame.width
        }
    }
    
    func setSpeakButtonStatus() {
        if !self.viewModel.getSpeakButtonStatus()! {
            btnSpeak.isHidden = self.viewModel.getSpeakButtonStatus()!
            speakButtonTrailingConstraint.constant = speakButtonTrailingConstraint.constant + btnSpeak.frame.width
        }
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib.init(nibName: nibMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {[weak self]
            event in
            if self?.viewModel.status.value == InputAStatus.loaded.rawValue {
                DispatchQueue.main.async {
                    guard let cell = self?.getCellForIndexPath(indexPath: ((self?.viewModel.getSelection())!)) else { return }
                    AnimationUtil.cancelMenuSelection(imageView: cell.ivStatusIcon)
                    self?.updateUi()
                }
            }
        }).disposed(by: disposeBag)
        
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue && AnimationUtil.getTag() == InputAViewController.TAG {
                print("Clicked")
                self.viewModel.onItemLoadRequest(indexPath: self.viewModel.getSelection(), page: self.page)
            }
        }).disposed(by: disposeBag)
    }
}

extension InputAViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    // FIXME: Fix the hardcode and update collection data properly
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getItems(for: page).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuItemCollectionViewCell
        
        self.viewModel.setItem(index: indexPath.row)
        cell.setCell(url: self.viewModel.getItemIcon(), label: self.viewModel.getItemTitle())
        
        return cell
    }
    
    // FIXME: Remove the hardcode
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let cellWidth = self.collectionView.frame.size.width / 5
        let cellHeight = self.collectionView.frame.size.height / 4

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.setSelection(indexPath: indexPath)
        guard let cell = self.getCellForIndexPath(indexPath: indexPath) else { return }
        AnimationUtil.animateMenuSelection(imageView: cell.ivStatusIcon, fingerTouch: true, tag: InputAViewController.TAG)
        
        self.viewModel.setItem(index: indexPath.row)
        
        if (indexPath.row >= self.viewModel.itemsCountOnPage-1) {
            page = page+1
        } else if (indexPath.row == 0 && page > 0) {
            page = page-1
        }
//        updateUi()
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

