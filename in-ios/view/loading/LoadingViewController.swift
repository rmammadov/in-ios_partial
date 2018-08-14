//
//  LoadingViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/14/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let segueIdentifierHome = "segueHome"

class LoadingViewController: BaseViewController {

    @IBOutlet weak var ivProgressbar: UIImageView!
    @IBOutlet weak var labelStatus: UILabel!
    
    let viewModel = LoadingViewModel()
    
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
        self.setLoadingScreen()
        self.setSubscribers()
    }
    
    func setViewModel() {
        self.viewModel.setSubscribers()
        self.viewModel.requestData()
    }
    
    func setSubscribers() {
        self.viewModel.status.asObservable().subscribe(onNext: {
            event in
            DispatchQueue.main.async {
                if self.viewModel.status.value == LoadingStatus.completed.rawValue {
                    self.showHome()
                }
            }
        })
    }
    
    func setLoadingScreen() {
        self.labelStatus.text = "Loading content..."
        AnimationUtil.animateLoading(imageView: self.ivProgressbar)
    }
    
    func showHome() {
        self.performSegue(withIdentifier: segueIdentifierHome, sender: self)
    }
}
