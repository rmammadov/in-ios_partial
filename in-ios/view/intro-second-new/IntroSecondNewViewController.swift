//
//  IntroSecondNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS = "showGenderOptions"

class IntroSecondNewViewController: BaseViewController {
    
    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfAgeGroup: INTextField!
    @IBOutlet weak var tfMedicalCondition: INTextField!
    
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
    
    @IBAction func onClickBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnContinue(_ sender: Any) {
        onContinue()
    }
}

extension IntroSecondNewViewController {
    
    func setUi() {
        tfName.delegate = self
        tfName.tag = 0
        tfAgeGroup.delegate = self
        tfAgeGroup.tag = 1
        tfMedicalCondition.delegate = self
        tfMedicalCondition.tag = 2
        self.setKeyboardInetraction()
    }
    
}

extension IntroSecondNewViewController {
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS, sender: self)
    }
}
