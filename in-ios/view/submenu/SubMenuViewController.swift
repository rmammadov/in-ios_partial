//
//  SubMenuViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let nibNameSubMenuItem = "SubMenuItemCollectionViewCell"
private let reuseIdentifier = "cellSubMenuItem"


class SubMenuViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = SubMenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setViewModel()
        self.setCollectionView()
        self.setSubscribers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension SubMenuViewController {
    
    func setViewModel() {
        self.viewModel.setParentVC(vc: self.getParentViewController())
        self.viewModel.setSubscribers()
    }
    
    func setCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: nibNameSubMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            self.collectionView.reloadData()
        })
    }
    
    func getParentViewController() -> HomeViewController {
        return self.parent as! HomeViewController
    }
}


extension SubMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getSubMenuItems()!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SubMenuItemCollectionViewCell

        cell.labelTitle.text = self.viewModel.getSubMenuItems()![indexPath.row].name
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnimationUtil.cancelSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: viewModel.getPreviousSelection()).ivStatusIcon)
        AnimationUtil.animateSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: indexPath).ivStatusIcon)
        self.viewModel.onItemClicked(indexPath: indexPath)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> SubMenuItemCollectionViewCell {
        let cell: SubMenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! SubMenuItemCollectionViewCell
        
        return cell
    }
}
