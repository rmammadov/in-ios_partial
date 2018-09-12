//
//  InputViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let nibMenuItem = "MenuItemCollectionViewCell"
private let reuseIdentifier = "cellMenuItem"
private let tileLineCount : CGFloat = 6.0
private let tileColumnCount : CGFloat = 4.0

class InputAViewController: BaseViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = InputAViewModel()
    
    var page = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSpeakBtn(_ sender: Any) {
    }
}

extension InputAViewController {
    
    func setUi() {
        self.setViewModel()
        self.setTitle()
        self.setSpeakButtonStatus()
        self.setCollectionView()
        self.setSubscribers()
    }
    
    func updateUi() {
        self.collectionView.reloadData()
    }
    
    func setViewModel() {
        self.viewModel.loadScreen()
    }
    
    func setTitle() {
        self.labelTitle.text = self.viewModel.getTitle()
    }
    
    func setSpeakButtonStatus() {
        self.btnSpeak.isHidden = self.viewModel.getSpeakButtonStatus()!
    }
    
    func setCollectionView() {
        self.collectionView.register(UINib.init(nibName: nibMenuItem, bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.viewModel.status.value == InputAStatus.loaded.rawValue {
                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        })
    }
}

extension InputAViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    // FIXME: Fix the hardcode and update collection data properly
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getItems(for: page).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuItemCollectionViewCell
        
        self.viewModel.setItem(index: indexPath.row)
        cell.labelTitle.text = self.viewModel.getItemTitle()
        cell.setIcon(url: self.viewModel.getItemIcon())
        
        return cell
    }
    
    // FIXME: Remove the hardcode
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = self.collectionView.frame.size.width / tileLineCount
        let cellHeight = self.collectionView.frame.size.height / tileColumnCount

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath.row >= 4) {
            page = page+1
        } else if (indexPath.row == 0 && page > 0) {
            page = page-1
        }
        collectionView.reloadData()
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> MenuItemCollectionViewCell {
        let cell: MenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! MenuItemCollectionViewCell
        
        return cell
    }
}

