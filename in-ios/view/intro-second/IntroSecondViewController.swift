//
//  IntroSecondViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroSecondViewController: BaseViewController {

    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfSurname: INTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension IntroSecondViewController {
    
    func setUi() {
        self.tfName.delegate = self
        self.tfName.tag = 0
        self.tfSurname.delegate = self
        self.tfSurname.tag = 1
    }
    
}


