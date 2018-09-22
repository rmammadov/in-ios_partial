//
//  LoadingViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let SEGUE_IDENTIFIER_INTRO = "segueIntro"
private let SEGUE_IDENTIFIER_HOME = "segueHome"

class LoadingViewController: BaseViewController {

    @IBOutlet weak var ivProgressbar: UIImageView!
    @IBOutlet weak var ivProgressbarContent: UIImageView!
    @IBOutlet weak var labelStatus: UILabel!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                    self.labelStatus.text = "No internet connection !"
                
                case LoadingStatus.failed.rawValue:
                    AnimationUtil.animateLoading(imageView: self.ivProgressbar)
                    self.ivProgressbar.image = UIImage(named: "ic_circle_gradient_fill")
                    self.ivProgressbarContent.image = UIImage(named: "ic_server_error")
                    self.labelStatus.text = "Failed to connect to the server !"
                
                case LoadingStatus.completed.rawValue:
                    self.showIntro()
                
                default:
                    self.ivProgressbarContent.image = nil
                    AnimationUtil.animateLoading(imageView: self.ivProgressbar)
                self.labelStatus.text = "Loading content..."
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
