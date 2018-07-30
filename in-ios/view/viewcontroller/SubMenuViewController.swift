//
//  SubMenuViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/30/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import Kingfisher

private let nibNameSubMenuItem = "SubMenuItemCollectionViewCell"
private let reuseIdentifier = "cellSubMenuItem"

class SubMenuViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = SubMenuViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupCollectionView()
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
    
    func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: nibNameSubMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
    }

}

extension SubMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SubMenuItemCollectionViewCell
        
        // Configure the cell
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AnimationUtil.cancelSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: viewModel.getPreviousSelection()).ivStatusIcon)
        AnimationUtil.animateSubMenuSelection(imageView: self.getCellForIndexPath(indexPath: indexPath).ivStatusIcon)
        self.viewModel.setPreviousSelection(indexPath: indexPath)
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> SubMenuItemCollectionViewCell {
        let cell: SubMenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! SubMenuItemCollectionViewCell
        
        return cell
    }
}
