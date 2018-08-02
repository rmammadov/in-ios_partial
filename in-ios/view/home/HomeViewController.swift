//
//  HomeViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let segueIdentifierSubMenu = "segueSubMenu"
private let nibTopMenuItem = "TopMenuItemCollectionViewCell"
private let reuseIdentifier = "cellTopMenuItem"

class HomeViewController: BaseViewController {

    @IBOutlet weak var collectionTopMenu: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var containerViewSubMenu: UIView!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setViewModel()
        self.setCollectionView()
        self.setSubscribers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationBar()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifierSubMenu {
          
        }
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.viewModel.onClickBackButton()
    }
}

extension HomeViewController {

    func setViewModel() {
        self.viewModel.setSubscribers()
        self.viewModel.requestData()
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
                    self.setUi()
                }
            }
        })
    }
    
    func setUi() {
        self.collectionTopMenu.reloadData()
        self.setBackButtonStatus()
    }
    
    func setBackButtonStatus() {
        self.btnBack.isHidden = self.viewModel.getBackButtonStatus()
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

