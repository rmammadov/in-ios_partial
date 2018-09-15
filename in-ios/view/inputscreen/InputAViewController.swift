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
    let disposeBag = DisposeBag()
    
    var page = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
    }
    
    deinit {
        setBackground(remove: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradient()
    }
    
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSpeakBtn(_ sender: Any) {
    }
}

extension InputAViewController {
    
    func getParentViewController() -> HomeViewController {
        return self.parent?.parent?.parent as! HomeViewController
    }
    
    func setupGradient() {
        if let parentVC = viewModel.parentVC {
            DispatchQueue.main.async {
                self.addGradient(height: self.getLastCellPositionHeight(from: self.collectionView, to: parentVC.ivBackground), in: parentVC.ivBackground)
            }
        }
    }
    
    fileprivate func addGradient(height: CGFloat, in targetView: UIView) {
        let gradientName = "backgroundGradient"
        var gradientLayer: CAGradientLayer!
        
        if let sublayers = targetView.layer.sublayers {
            sublayers.forEach { (subLayer) in
                if subLayer.name == gradientName, let gradient = subLayer as? CAGradientLayer {
                    gradientLayer = gradient
                }
            }
        }
        
        // animate function
        func animate(gradient: CAGradientLayer) {
            let gradientChangeLocation = CABasicAnimation(keyPath: "locations")
            gradientChangeLocation.duration = 2
            gradientChangeLocation.isRemovedOnCompletion = false
            gradient.add(gradientChangeLocation, forKey: "locationsChange")
        }
        
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer.name = gradientName
            targetView.layer.insertSublayer(gradientLayer, at: 0)
            animate(gradient: gradientLayer)
        }
        
        // TODO: need to think about alghritm how to proportionally adjust locations to make smooth gradient with any frame height
        gradientLayer.locations = [0.0, 0.4, 0.6, 0.8, 1] as [NSNumber]
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.9).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: targetView.frame.width, height: height)
    }
    
    func setUi() {
        self.setViewModel()
        self.setTitle()
        self.setSpeakButtonStatus()
        self.setCollectionView()
        self.setSubscribers()
        setBackground(remove: false)
    }
    
    func setBackground(remove: Bool) {
        if remove == true {
            viewModel.parentVC?.ivBackground.kf.setImage(with: nil)
            return
        }
        if let backgroundUrl = viewModel.getBackground() {
            viewModel.parentVC?.ivBackground.kf.setImage(with: URL(string: backgroundUrl))
        } else {
            viewModel.parentVC?.ivBackground.kf.setImage(with: nil)
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
    
    func updateUi() {
        collectionView.reloadData()
        setupGradient()
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
        self.viewModel.status.asObservable().subscribe(onNext: {[weak self]
            event in
            if self?.viewModel.status.value == InputAStatus.loaded.rawValue {
                DispatchQueue.main.async {
                    self?.updateUi()
                }
            }
        }).disposed(by: disposeBag)
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
        updateUi()
    }
    
    func getCellForIndexPath(indexPath: IndexPath) -> MenuItemCollectionViewCell {
        let cell: MenuItemCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! MenuItemCollectionViewCell
        
        return cell
    }
    
    fileprivate func getLastCellPositionHeight(from collectionView: UICollectionView, to parentView: UIView) -> CGFloat {
        let lastIndexPath = IndexPath(item: viewModel.getItems(for: page).count-1, section: 0)
        if let attributes = collectionView.layoutAttributesForItem(at:lastIndexPath)  {
            let cellRectInSV = collectionView.convert(attributes.frame, to: parentView)
            return cellRectInSV.maxY
        }
        return 0.0
    }
}

