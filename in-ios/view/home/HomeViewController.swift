//
//  HomeViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

private let SEGUE_IDENTIFIER_MENU = "segueMenu"

private let nibTopMenuItem = "TopMenuItemCollectionViewCell"
private let reuseIdentifier = "cellTopMenuItem"
private let nibTopMenuItemExpanded = "TopMenuItemExpandedCollectionViewCell"
private let reuseIdentifierExpanded = "cellTopMenuItemExpanded"

class HomeViewController: BaseViewController {

    private static let TAG = "HomeViewController"
    
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var viewOpacity: UIView!
    @IBOutlet weak var viewTopMenu: UIView!
    @IBOutlet weak var collectionTopMenu: UICollectionView!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewSubMenu: UIView!
    
    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
//        setCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        onOrientationChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

extension HomeViewController {
    
    var cellIdentifier: String {
        return MainMenuItemCollectionViewCell.identifier
    }

    func setUi() {
        setViewModel()
        setCollectionView()
        setSubscribers()
        updateUi()
    }
    
    func setViewModel() {
        viewModel.setData()
    }
    
    func setCollectionView() {
        
        self.collectionTopMenu.register(UINib(nibName: cellIdentifier, bundle: nil),
                                        forCellWithReuseIdentifier: cellIdentifier)
        self.collectionTopMenu.register(UINib.init(nibName: nibTopMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionTopMenu.register(UINib.init(nibName: nibTopMenuItemExpanded, bundle: nil), forCellWithReuseIdentifier:reuseIdentifierExpanded)
        self.collectionTopMenu.dataSource = self
        self.collectionTopMenu.delegate = self
    }
    
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.viewModel.status.value == BackgroundStatus.set.rawValue {
                DispatchQueue.main.async {
                    self.setBackground()
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.getMenuExpandedObservable().subscribe(onNext: { (isExpanded) in
            self.updateTopMenu()
        }).disposed(by: disposeBag)
    }
    
    func updateUi() {
        self.collectionTopMenu.reloadData()
        updateTopMenu()
    }
    
    // TODO: Hardcode should be removed
    
    func updateTopMenu() {
        updateMainMenu()
//        if viewModel.getIsMenuExpanded(){
//            self.constraintCollectionViewHeight.constant = 116
//        } else {
//            self.constraintCollectionViewHeight.constant = 64
//        }
//        self.collectionTopMenu.layoutIfNeeded()
//        self.collectionTopMenu.reloadData()
    }
    
    private func updateMainMenu() {
        if viewModel.getIsMenuExpanded() {
            self.constraintCollectionViewHeight.constant = 116
        } else {
            self.constraintCollectionViewHeight.constant = 64
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.collectionTopMenu.collectionViewLayout.invalidateLayout()
            self.collectionTopMenu.visibleCells.forEach({ (cell) in
                guard let cell = cell as? MainMenuItemCollectionViewCell else { return }
                if self.viewModel.getIsMenuExpanded() {
                    cell.maximize(toHeight: 116)
                } else {
                    cell.minimize(toHeight: 64)
                }
            })
        }
    }
    
    func setBackground() {
        guard
            let background = viewModel.getBackground(),
            let url = URL(string: background)
            else {return}
        let alpha  = viewModel.getBackgroundAlpha()
        ivBackground.kf.setImage(with: url)
        ivBackground.alpha = alpha
    }
    
    func setCamera() {
        // TODO: should be removed and reimplemented after tests
        let cameraManager: CameraManager = CameraManager(cameraView: self.viewOpacity)

        cameraManager.askUserForCameraPermission { (status) in
            if status {
                cameraManager.setPrediction()
                cameraManager.setCamera()
                cameraManager.startSession()
                cameraManager.shouldRespondToOrientationChanges = true
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel.getTopMenuItems()?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        viewModel.setItem(index: indexPath.row)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? MainMenuItemCollectionViewCell else { fatalError() }
        let item = viewModel.getItem(for: indexPath)
        cell.setupView(MainMenuItemCollectionViewCell.ViewModel(title: item.translations.first?.label ?? item.name,
                                                                url: item.icon?.url))
        viewModel.getIsMenuExpanded() ? cell.maximize(animated: false, toHeight: cell.bounds.height) : cell.minimize(animated: false, toHeight: cell.bounds.height)
        cell.setSelected(viewModel.getTopMenuItemSelected() == indexPath)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setMenuExpanded(true)
        setTopMenuItemSelected(indexPath: indexPath)
        viewModel.onTopMenuItemSelected(indexPath: indexPath)
    }
    
    // TODO: Hardcode should be removed
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = self.collectionTopMenu.frame.size.width / 3
        let cellHeight: CGFloat = 116
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth : CGFloat = self.collectionTopMenu.frame.size.width / 3
        
        switch self.collectionTopMenu.numberOfItems(inSection: self.collectionTopMenu.numberOfSections - 1) {
            case 1:
                return UIEdgeInsets.init(top: 0, left: cellWidth, bottom: 0, right: cellWidth)
            case 2:
                if self.viewModel.getTopMenuItemSelected().row == 0 {
                    return UIEdgeInsets.init(top: 0, left: cellWidth, bottom: 0, right: 0)
                } else {
                    return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: cellWidth)
                }
            default:
                return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func setTopMenuItemSelected(indexPath: IndexPath) {
        guard let previousActiveCell = collectionTopMenu.cellForItem(at: viewModel.getTopMenuItemSelected()) as? MainMenuItemCollectionViewCell,
            let currentActiveCell = collectionTopMenu.cellForItem(at: indexPath) as? MainMenuItemCollectionViewCell
            else { return }
        previousActiveCell.setSelected(false)
        currentActiveCell.setSelected(true)
    }
    
    func onOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionTopMenu.collectionViewLayout.invalidateLayout()
            self.collectionTopMenu.reloadData()
        }
    }
}

