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
    private var isDisappear: Bool = true
    
    let viewModel = InputAViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDisappear = false
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
                let storyboard = UIStoryboard(name: "ScreenTypeC", bundle: nil)
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
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue && AnimationUtil.getTag() == InputAViewController.TAG {
                print(self.isBeingPresented)
                self.viewModel.onItemLoadRequest(indexPath: self.viewModel.getSelection())
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
        let marginSpace = CGFloat(viewModel.getItemMargin() * (viewModel.getRowCount() - 1))
        var cellWidth = (self.collectionView.frame.size.width - marginSpace) / CGFloat(viewModel.getColumnCount())
        let cellHeight = self.collectionView.frame.size.height / CGFloat(viewModel.getRowCount())
        if cellWidth > cellHeight {
            cellWidth = cellHeight - (7.0 + 7.0 + 17.0)
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
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
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.setSelection(indexPath: indexPath)
        guard let cell = self.getCellForIndexPath(indexPath: indexPath) else { return }
        AnimationUtil.animateMenuSelection(imageView: cell.ivStatusIcon, fingerTouch: false, tag: InputAViewController.TAG)
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

