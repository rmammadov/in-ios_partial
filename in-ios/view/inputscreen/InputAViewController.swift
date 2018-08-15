//
//  InputViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class InputAViewController: BaseViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnSpeak: UIButton!
    
    let viewModel = InputAViewModel()
    
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
    }
    
    func setViewModel() {
        self.viewModel.loadScreen()
    }
    
    func setTitle() {
        self.labelTitle.text = self.viewModel.getTitle()
    }
    
    func setSpeakButtonStatus() {
        self.btnSpeak.isHidden = !self.viewModel.getSpeakButtonStatus()!
    }
}
