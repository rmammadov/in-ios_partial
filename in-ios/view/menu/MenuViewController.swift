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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
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
                    guard let cell = self.getCellForIndexPath(indexPath: self.viewModel.getSelection()) else { return }
                    AnimationUtil.cancelMenuSelection(imageView: cell.ivStatusIcon)
                } else {
                    // Dissmis all view controllers which overlapping main view
                    self.navigationController?.popToRootViewController(animated: true)
                    self.collectionView.reloadData()
                }
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.statusInput.asObservable().subscribe(onNext: {
            event in
            DispatchQueue.main.async {
                if self.viewModel.statusInput.value == InputScreenId.inputScreen0.rawValue {
                    self.performSegue(withIdentifier: SEGUE_IDENTIFIER_INPUT, sender: self)
                    AnimationUtil.cancelMenuSelection(imageView: self.getCellForIndexPath(indexPath: self.viewModel.getSelection())!.ivStatusIcon)
                }
            }
        }).disposed(by: disposeBag)
        
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue && AnimationUtil.getTag() == MenuViewController.TAG {
                self.viewModel.onItemLoadRequest(indexPath: self.viewModel.getSelection())
            }
        }).disposed(by: disposeBag)
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
        AnimationUtil.cancelMenuSelection(imageView: cell.ivStatusIcon)
        
        return cell
    }
    
    // TODO: Hardcode must be removed
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
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
        guard let cell = getCellForIndexPath(indexPath: indexPath) else { return }
        AnimationUtil.animateMenuSelection(imageView: cell.ivStatusIcon, fingerTouch: false, tag: MenuViewController.TAG)
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
