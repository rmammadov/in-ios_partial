//
//  SubMenuViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let SEGUE_IDENTIFIER_SUB_MENU = "segueSubMenu"
private let SEGUE_IDENTIFIER_INPUT = "segueInputA"

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"

class MenuViewController: BaseViewController {
    
    private static let TAG = "MenuViewController"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = MenuViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.onViewLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerGazeTrackerObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterGazeTrackerObserver()
        cancelLastSelection()
        viewModel.setSelection(indexPath: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        onOrientationChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == SEGUE_IDENTIFIER_INPUT {
            let vc = segue.destination as! InputAViewController
            vc.viewModel.setParentMenuItem(item: self.viewModel.getSelectedItem()!)
        } else if segue.identifier == SEGUE_IDENTIFIER_SUB_MENU {
            let vc = segue.destination as! SubMenuViewController
            vc.viewModel.setParentMenuItem(item: self.viewModel.getSelectedItem()!)
        }
    }
}

extension MenuViewController {
    
    // TODO: Put strings in resource file
    
    func onViewLoad() {
        self.setViewModel()
        self.setCollectionView()
        self.setSubscribers()
    }
    
    func setViewModel() {
        self.viewModel.setParentVC(vc: self.getParentViewController())
        self.viewModel.setSubscribers()
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib.init(nibName: nibMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            DispatchQueue.main.async {
                if self.viewModel.status.value == MenuStatus.secondPhaseLoaded.rawValue {
                    self.performSegue(withIdentifier: SEGUE_IDENTIFIER_SUB_MENU, sender: self)
                    guard let indexPath = self.viewModel.getSelection(),
                        let cell = self.getCellForIndexPath(indexPath: indexPath) else { return }
                    AnimationUtil.cancelAnimation(object: cell)
                } else {
                    // Dissmis all view controllers which overlapping main view
                    self.navigationController?.popToRootViewController(animated: true)
                    self.collectionView.reloadData()
                    self.viewModel.setSelection(indexPath: nil)
                }
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.statusInput.asObservable().subscribe(onNext: { event in
            DispatchQueue.main.async {
                switch event {
                case InputScreenId.inputScreen0.rawValue:
                    self.loadInputScreen0()
                case InputScreenId.settingsAccount.rawValue:
                    self.loadSettingsAccount()
                case InputScreenId.settingsInterface.rawValue:
                    self.loadSettingsInterface()
                default: return
                }
            }
        }).disposed(by: disposeBag)
        
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue
                && AnimationUtil.getTag() == MenuViewController.TAG {
                guard let indexPath = self.viewModel.getSelection() else { return }
                self.viewModel.onItemLoadRequest(indexPath: indexPath)
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChanged(_:)), name: .LanguageChanged, object: nil)
    }
    
    private func loadInputScreen0() {
        guard
            let inputScreenId = self.viewModel.getSelectedItem()?.inputScreenId,
            let indexPath = self.viewModel.getSelection(),
            let cell = self.getCellForIndexPath(indexPath: indexPath),
            let inputScreen = DataManager.getInputScreens().getInputScreenFor(id: inputScreenId)
            else { return }
        AnimationUtil.cancelAnimation(object: cell)
        self.viewModel.setSelection(indexPath: nil)
        switch inputScreen.type {
        case .inputScreenA:
            self.performSegue(withIdentifier: SEGUE_IDENTIFIER_INPUT, sender: self)
        case .inputScreenC:
            self.openScreenTypeC(inputScreen: inputScreen)
        default: break
        }
    }
    
    private func loadSettingsAccount() {
        if let indexPath = viewModel.getSelection(), let cell = getCellForIndexPath(indexPath: indexPath) {
            AnimationUtil.cancelAnimation(object: cell)
            viewModel.setSelection(indexPath: nil)
        }
        guard let accountVC = storyboard?.instantiateViewController(withIdentifier: SettingsAccountViewController.identifier) as? SettingsAccountViewController else { return }
        navigationController?.pushViewController(accountVC, animated: true)
    }
    
    private func loadSettingsInterface() {
        if let indexPath = viewModel.getSelection(), let cell = getCellForIndexPath(indexPath: indexPath) {
            AnimationUtil.cancelAnimation(object: cell)
            viewModel.setSelection(indexPath: nil)
        }
        guard let interfaceVC = storyboard?.instantiateViewController(withIdentifier: SettingsInterfaceViewController.identifier) as? SettingsInterfaceViewController else { return }
        navigationController?.pushViewController(interfaceVC, animated: true)
    }
    
    private func openScreenTypeC(inputScreen: InputScreen) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let nextVC = storyboard.instantiateViewController(withIdentifier: "ScreenTypeCViewController") as? ScreenTypeCViewController
            else { return }
        nextVC.viewModel.inputScreen = inputScreen
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func getParentViewController() -> HomeViewController {
        return self.parent?.parent?.parent as! HomeViewController
    }
}


extension MenuViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getMenuItems()!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuItemCollectionViewCell
        
        self.viewModel.setItem(index: indexPath.row)
        cell.setCell(url: self.viewModel.getItemIcon(), label: self.viewModel.getItemTitle())
        cell.setSelected(false)
//        AnimationUtil.cancelMenuSelection(imageView: cell.ivStatusIcon)
        
        return cell
    }
    
    // TODO: Hardcode must be removed
    
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
        guard let cell: MenuItemCollectionViewCell =
            self.collectionView.cellForItem(at: indexPath) as? MenuItemCollectionViewCell
            else { return nil}
        return cell
    }
    
    func onOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
}


extension MenuViewController: GazeTrackerUpdateProtocol {
    func gazeTrackerUpdate(coordinate: CGPoint) {
        guard let mainView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        let newPoint = mainView.convert(coordinate, to: self.collectionView)
        selectCellAt(indexPath: self.collectionView.indexPathForItem(at: newPoint))
    }
    
    func selectCellAt(indexPath: IndexPath?, fingerTouch: Bool = false) {
        guard indexPath != self.viewModel.getSelection() else { return }
        cancelLastSelection()
        self.viewModel.setSelection(indexPath: indexPath)
        guard let indexPath = indexPath, let cell = getCellForIndexPath(indexPath: indexPath) else { return }
        AnimationUtil.animateSelection(object: cell, fingerTouch: fingerTouch, tag: MenuViewController.TAG)
        if let homeVC = self.parent?.parent?.parent as? HomeViewController {
            homeVC.viewModel.setMenuExpanded(false)
        }
    }
    
    private func cancelLastSelection() {
        if let lastIndexPath = self.viewModel.getSelection(),
            let cell = getCellForIndexPath(indexPath: lastIndexPath) {
            AnimationUtil.cancelAnimation(object: cell)
        }
    }
}

extension MenuViewController {
    @objc func languageDidChanged(_ notification: Notification) {
        collectionView.reloadData()
    }
}
