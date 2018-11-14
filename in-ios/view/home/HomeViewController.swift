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
        setCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerGazeTrackerObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CameraManager.shared.setup(cameraView: viewOpacity, showPreview: false, showLabel: false, showPointer: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        onOrientationChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterGazeTrackerObserver()
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
    }
    
    private func updateMainMenu() {
        let height: CGFloat = viewModel.getIsMenuExpanded() ? 116 : 64
        guard self.constraintCollectionViewHeight.constant != height else { return }
        self.constraintCollectionViewHeight.constant = height
        unregisterGazeTrackerObserver()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.collectionTopMenu.performBatchUpdates({
                self.collectionTopMenu.collectionViewLayout.invalidateLayout()
            })
        }, completion: { (_) in
            self.registerGazeTrackerObserver()
        })
        UIView.animate(withDuration: 0.5) {
            
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
        let cameraManager = CameraManager.shared
//        cameraManager.setup(cameraView: viewOpacity, showPreview: false, showLabel: false, showPointer: true)

        cameraManager.askUserForCameraPermission { (status) in
            guard status else { return }
            cameraManager.setCamera()
            cameraManager.startSession()
            cameraManager.shouldRespondToOrientationChanges = true
            cameraManager.updateOrientation()
        }
        cameraManager.updateOrientation()
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
        cell.setupView(MainMenuItemCollectionViewCell.ViewModel(title: item.translations.currentTranslation()?.label ?? item.name,
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
        collectionTopMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // TODO: Hardcode should be removed
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth: CGFloat = (collectionView.bounds.width * 0.6) / 3
        let cellHeight: CGFloat = collectionView.bounds.height
        
        let size = CGSize(width: cellWidth, height: cellHeight)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth : CGFloat = (collectionTopMenu.bounds.width * 0.6) / 3
        let inset = (collectionTopMenu.bounds.width - cellWidth) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
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
            let cameraManager = CameraManager.shared
            cameraManager.updateOrientation(completion: { [weak self] (isSuccess) in
                guard let `self` = self, !isSuccess else { return }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let calibrationVC = storyboard.instantiateViewController(withIdentifier: IntroThirdNewViewController.identifier)
                self.present(calibrationVC, animated: true, completion: nil)
            })
        }
    }
}

extension HomeViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        let isInTopMenu = viewTopMenu.frame.contains(coordinate)
        let isInContainer = containerViewSubMenu.frame.contains(coordinate)
        if isInTopMenu {
            if viewModel.getIsMenuExpanded() {
                let point = view.convert(coordinate, to: collectionTopMenu)
                if let indexPath = collectionTopMenu.indexPathForItem(at: point) {
                    setTopMenuItemSelected(indexPath: indexPath)
                    viewModel.onTopMenuItemSelected(indexPath: indexPath)
                    collectionTopMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            } else {
                viewModel.setMenuExpanded(true)
                updateTopMenu()
            }
        }
        if isInContainer {
            if viewModel.getIsMenuExpanded() {
                viewModel.setMenuExpanded(false)
                updateTopMenu()
            }
        }
    }
}
