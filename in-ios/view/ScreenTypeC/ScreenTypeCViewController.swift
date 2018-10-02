//
//  ScreenTypeCViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 02/10/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class ScreenTypeCViewController: BaseViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var mainCollectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    let viewModel = ScreenTypeCViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSpeakButtonClick(_ sender: Any) {
        
    }
    
}
