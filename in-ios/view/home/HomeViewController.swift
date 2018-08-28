//
//  HomeViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import Kingfisher

private let segueIdentifierMenu = "segueMenu"
private let nibTopMenuItem = "TopMenuItemCollectionViewCell"
private let reuseIdentifier = "cellTopMenuItem"
private let nibTopMenuItemExpanded = "TopMenuItemExpandedCollectionViewCell"
private let reuseIdentifierExpanded = "cellTopMenuItemExpanded"

class HomeViewController: BaseViewController {

    @IBOutlet weak var viewTopMenu: UIView!
    @IBOutlet weak var collectionTopMenu: UICollectionView!
    @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewSubMenu: UIView!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    func setUi() {
        setViewModel()
        setCollectionView()
        setSubscribers()
    }
    
    func setViewModel() {
        viewModel.setData()
    }
    
    func setCollectionView() {
        self.collectionTopMenu.register(UINib.init(nibName: nibTopMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionTopMenu.register(UINib.init(nibName: nibTopMenuItemExpanded, bundle: nil), forCellWithReuseIdentifier:reuseIdentifierExpanded)
        self.collectionTopMenu.dataSource = self
        self.collectionTopMenu.delegate = self
    }
    
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.viewModel.status.value == TopMenuStatus.loaded.rawValue {
                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        })
    }
    
    func updateUi() {
        self.collectionTopMenu.reloadData()
        updateTopMenu()
    }
    
    // TODO: Hardcode should be removed
    
    func updateTopMenu() {
        if viewModel.getIsMenuExpanded(){
            self.constraintCollectionViewHeight.constant = 116
        } else {
            self.constraintCollectionViewHeight.constant = 64
        }
        self.collectionTopMenu.layoutIfNeeded()
        self.collectionTopMenu.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel.getTopMenuItems()?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuItem = self.viewModel.getTopMenuItems()![indexPath.row]
        
        viewModel.setItem(index: indexPath.row)
        
        if viewModel.getIsMenuExpanded() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierExpanded, for: indexPath as IndexPath) as! TopMenuItemExpandedCollectionViewCell
            
            cell.setIcon(url: viewModel.getItemIcon())
            cell.label.text = viewModel.getItemTitle()
            
            if indexPath == viewModel.getTopMenuItemSelected() {
                cell.setSelected(isSelected: true)
            } else {
                cell.setSelected(isSelected: false)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! TopMenuItemCollectionViewCell
            
            cell.setIcon(url: viewModel.getItemIcon())
            cell.labelPassive.text = viewModel.getItemTitle()
            cell.labelActive.text = viewModel.getItemTitle()
            
            if indexPath == viewModel.getTopMenuItemSelected() {
                cell.setSelected(isSelected: true)
            } else {
                cell.setSelected(isSelected: false)
            }
            
            return cell
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setTopMenuItemSelected(indexPath: indexPath)
        viewModel.onTopMenuItemSelected(indexPath: indexPath)
    }
    
    // TODO: Hardcode should be removed
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = self.collectionTopMenu.frame.size.width / 3
        let cellHeight: CGFloat = 116
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> UICollectionViewCell? {
        var cell: UICollectionViewCell?
        if viewModel.getIsMenuExpanded() {
            cell = self.collectionTopMenu.cellForItem(at: indexPath) as! TopMenuItemExpandedCollectionViewCell
        } else {
            cell = self.collectionTopMenu.cellForItem(at: indexPath) as! TopMenuItemCollectionViewCell
        }
        
        return cell
    }
    
    func setTopMenuItemSelected(indexPath: IndexPath) {
        if viewModel.getIsMenuExpanded() {
            let previousActiveCell = self.getCellForIndexPath(indexPath: viewModel.getTopMenuItemSelected())
            as! TopMenuItemExpandedCollectionViewCell
            previousActiveCell.setSelected(isSelected: false)
            let currentActiveCell = self.getCellForIndexPath(indexPath: indexPath) as! TopMenuItemExpandedCollectionViewCell
            currentActiveCell.setSelected(isSelected: true)
        } else {
            let previousActiveCell = self.getCellForIndexPath(indexPath: viewModel.getTopMenuItemSelected()) as! TopMenuItemCollectionViewCell
            previousActiveCell.setSelected(isSelected: false)
            let currentActiveCell = self.getCellForIndexPath(indexPath: indexPath) as! TopMenuItemCollectionViewCell
            currentActiveCell.setSelected(isSelected: true)
        }
    }
}

