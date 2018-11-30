//
//  IntroSecondViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/9/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS = "showGenderOptions"

class IntroSecondViewController: BaseViewController {

    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfSurname: INTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
        setLastState(view: self)
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
    
    @IBAction func onClickContinueBtn(_ sender: Any) {
        onContinue()
    }
    
}

extension IntroSecondViewController {
    
    func setUi() {
        self.tfName.delegate = self
        self.tfName.tag = 0
        self.tfSurname.delegate = self
        self.tfSurname.tag = 1
        self.setKeyboardInetraction()
    }
    
}

extension IntroSecondViewController {
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS, sender: self)
    }
}

