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

class HomeViewController: BaseViewController {

    @IBOutlet weak var viewTopMenu: UIView!
    @IBOutlet weak var constraintTopMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionTopMenu: UICollectionView!
    @IBOutlet weak var containerViewSubMenu: UIView!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
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
        self.showNavigationBar()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

extension HomeViewController {

    func setUi() {
        self.setViewModel()
        self.setCollectionView()
        self.setSubscribers()
    }
    
    func setViewModel() {
        self.viewModel.setData()
    }
    
    func setCollectionView() {
        self.collectionTopMenu.register(UINib.init(nibName: nibTopMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
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
        self.collectionTopMenu.layoutIfNeeded()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.viewModel.getTopMenuItems()?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! TopMenuItemCollectionViewCell
        
        let menuItem = self.viewModel.getTopMenuItems()![indexPath.row]
        
        if menuItem.icon != nil {
            let url = URL(string: (menuItem.icon?.url)!)
            cell.ivIcon.kf.indicatorType = .activity
            cell.ivIcon.kf.setImage(with: url)
        }
        
        cell.labelPassive.text = menuItem.name
        cell.labelActive.text = menuItem.name
        
        if indexPath == self.viewModel.getTopMenuItemSelected() {
            cell.labelPassive.isHidden = true
            cell.viewActive.isHidden = false
        } else {
            cell.viewActive.isHidden = true
            cell.labelPassive.isHidden = false
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.setTopMenuItemSelected(indexPath: indexPath)
        self.viewModel.onTopMenuItemSelected(indexPath: indexPath)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> TopMenuItemCollectionViewCell {
        let cell: TopMenuItemCollectionViewCell = self.collectionTopMenu.cellForItem(at: indexPath) as! TopMenuItemCollectionViewCell
        
        return cell
    }
    
    func setTopMenuItemSelected(indexPath: IndexPath) {
        let previousActiveCell = self.getCellForIndexPath(indexPath: self.viewModel.getTopMenuItemSelected())
        previousActiveCell.viewActive.isHidden = true
        previousActiveCell.labelPassive.isHidden = false
        let currentActiveCell = self.getCellForIndexPath(indexPath: indexPath)
        currentActiveCell.labelPassive.isHidden = true
        currentActiveCell.viewActive.isHidden = false
    }
}

