//
//  SubMenuViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"

private let segueIdentifierSubMenu = "segueSubMenu"
private let segueIdentifierInput = "segueInputA"

class MenuViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = MenuViewModel()
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueIdentifierInput {
            let vc = segue.destination as! InputAViewController
            vc.viewModel.setParentMenuItem(item: self.viewModel.getSelectedItem()!)
        } else if segue.identifier == segueIdentifierSubMenu {
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
                    self.performSegue(withIdentifier: segueIdentifierSubMenu, sender: self)
                    AnimationUtil.cancelSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: self.viewModel.getSelection()).ivStatusIcon)
                } else {
                    self.collectionView.reloadData()
                }
            }
        })
        
        self.viewModel.statusInput.asObservable().subscribe(onNext: {
            event in
            DispatchQueue.main.async {
                if self.viewModel.statusInput.value == InputScreenId.inputScreen0.rawValue {
                    self.performSegue(withIdentifier: segueIdentifierInput, sender: self)
                    AnimationUtil.cancelSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: self.viewModel.getSelection()).ivStatusIcon)
                }
            }
        })
        
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue {
                self.viewModel.onItemLoadRequest(indexPath: self.viewModel.getSelection())
            }
        })
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

        let menuItem = self.viewModel.getMenuItems()![indexPath.row]
        
        if menuItem.icon != nil {
            let url = URL(string: (menuItem.icon?.url)!)
            cell.ivIcon.kf.indicatorType = .activity
            cell.ivIcon.kf.setImage(with: url)
        }
        
        cell.labelTitle.text = menuItem.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = self.collectionView.frame.size.width / 5
        let cellHeight = self.collectionView.frame.size.height / 4
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnimationUtil.animateSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: indexPath).ivStatusIcon)
        self.viewModel.setSelection(indexPath: indexPath)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> MenuItemCollectionViewCell {
        let cell: MenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! MenuItemCollectionViewCell
        
        return cell
    }
}
