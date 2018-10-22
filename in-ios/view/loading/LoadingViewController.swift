//
//  LoadingViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let SEGUE_IDENTIFIER_INTRO = "showIntro"
private let SEGUE_IDENTIFIER_HOME = "showHome"

class LoadingViewController: BaseViewController {

    @IBOutlet weak var ivProgressbar: UIImageView!
    @IBOutlet weak var ivProgressbarContent: UIImageView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var btnTryAgain: UIButton!
    
    let viewModel = LoadingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onClickBtnTryAgain(_ sender: Any) {
        self.viewModel.requestData()
    }
    
}

extension LoadingViewController {
    
    func setUi() {
        self.setViewModel()
        self.setLoadingScreenStatus()
        self.setSubscribers()
    }
    
    func setViewModel() {
        self.viewModel.setSubscribers()
        self.viewModel.requestData()
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            self.setLoadingScreenStatus()
        }).disposed(by: disposeBag)
    }
    
    func setLoadingScreenStatus() {
        DispatchQueue.main.async {
            switch self.viewModel.status.value {
                case LoadingStatus.noInternetConnection.rawValue:
                    AnimationUtil.animateLoading(imageView: self.ivProgressbar)
                    self.ivProgressbar.image = UIImage(named: "ic_circle_gradient_fill")
                    self.ivProgressbarContent.image = UIImage(named: "ic_no_internet")
                    self.labelStatus.text = "No internet connection!"
                    self.btnTryAgain.isHidden = false
                
                case LoadingStatus.failed.rawValue:
                    AnimationUtil.animateLoading(imageView: self.ivProgressbar)
                    self.ivProgressbar.image = UIImage(named: "ic_circle_gradient_fill")
                    self.ivProgressbarContent.image = UIImage(named: "ic_server_error")
                    self.labelStatus.text = "Failed to connect to the server!"
                    self.btnTryAgain.isHidden = false
                
                case LoadingStatus.completed.rawValue:
                    self.showIntro()
//                    self.showHome()
                
                default:
                    self.ivProgressbarContent.image = nil
                    AnimationUtil.animateLoading(imageView: self.ivProgressbar)
                    self.labelStatus.text = "Loading content..."
                    self.btnTryAgain.isHidden = true
            }
        }
    }
    
    func showIntro() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SEGUE_IDENTIFIER_INTRO, sender: self)
        }
    }
    
    func showHome() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SEGUE_IDENTIFIER_HOME, sender: self)
        }
    }
}
