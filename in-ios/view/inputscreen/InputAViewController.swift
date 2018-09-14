//
//  InputViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import AVKit
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
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var speakButtonTrailingConstraint: NSLayoutConstraint!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        getPointBottomCellPoint()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        setBackground()
    }
    
    func setBackground() {
        
        if let backgroundUrl = viewModel.getBackground() {
            viewModel.parentVC?.ivBackground.kf.setImage(with: URL(string: backgroundUrl))
        } else {
            viewModel.parentVC?.ivBackground.kf.setImage(with: nil)
        }
    }
    
    func getParentViewController() -> HomeViewController {
        return self.parent?.parent?.parent as! HomeViewController
    }
    
    func getPointBottomCellPoint() {
        
        if let lastVisibleCell = collectionView.indexPathsForVisibleItems.last  {
            let attributes = collectionView.layoutAttributesForItem(at:lastVisibleCell)!
            let cellRect = attributes.frame
            let cellRectInSV = collectionView.convert(cellRect, to: collectionView.superview)

            setGradientBackground(to: cellRectInSV.maxY+cellRectInSV.height)
        }
    }
    
    func setSpeakButtonStatus() {

        if self.viewModel.getSpeakButtonStatus()! {
            btnBack.isHidden = true
            btnSpeak.isHidden = true
            backButtonLeadingConstraint.constant = backButtonLeadingConstraint.constant - btnBack.frame.width
            speakButtonTrailingConstraint.constant = speakButtonTrailingConstraint.constant + btnSpeak.frame.width
        } else {
            btnBack.isHidden = false
            btnSpeak.isHidden = false
            backButtonLeadingConstraint.constant = 0
            speakButtonTrailingConstraint.constant = 0
        }
    }
    
    func setGradientBackground(to endGradientHeight: CGFloat) {

        let gradientLayer = CAGradientLayer()
        let gradientHeight = endGradientHeight/view.frame.height

        gradientLayer.locations = [0.0, gradientHeight-0.5, gradientHeight-0.2, gradientHeight] as [NSNumber]
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.darkGray.cgColor, UIColor.clear.cgColor]
        gradientLayer.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)

        viewModel.parentVC?.ivBackground.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateUi() {
        self.collectionView.reloadData()
    }
    
    func setViewModel() {
        self.viewModel.loadScreen()
        self.viewModel.setParentVC(vc: self.getParentViewController())
    }
    
    func setTitle() {
        self.labelTitle.text = self.viewModel.getTitle()
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
        cell.setCell(url: self.viewModel.getItemIcon(), text: self.viewModel.getItemTitle())
        
        return cell
    }
    
    // FIXME: Remove the hardcode
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = self.collectionView.frame.size.width / tileLineCount
        let cellHeight = self.collectionView.frame.size.height / tileColumnCount

        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let speechSynthesizer = AVSpeechSynthesizer()
        self.viewModel.setItem(index: indexPath.row)
        let text = self.viewModel.getItemTitle()
        
        let speechUtterance = AVSpeechUtterance(string: text!)
        speechSynthesizer.speak(speechUtterance)
        
        if (indexPath.row >= self.viewModel.itemsCountOnPage-1) {
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

