//
//  IntroSecondNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS = "showGenderOptions"

private let TAG_AGE_GROUP = 10
private let TAG_MEDİCAL_CONDİTİON = 11

class IntroSecondNewViewController: BaseViewController {
    
    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfAgeGroup: INTextField!
    @IBOutlet weak var tfMedicalCondition: INTextField!
    
    private var pickerAgeGroup: UIPickerView?
    private var pickerMedicalCondition: UIPickerView?
    
    private let viewModel: IntroSeconNewViewModel = IntroSeconNewViewModel()
    
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
        
        setPickerAgeGroup()
        setPickerMedicalCondition()
    }
    
    func setPickerAgeGroup() {
        pickerAgeGroup = UIPickerView()
        pickerAgeGroup?.dataSource = self
        pickerAgeGroup?.delegate = self
        pickerAgeGroup?.tag = TAG_AGE_GROUP
        
        self.tfAgeGroup.inputView = pickerAgeGroup
    }
    
    func setPickerMedicalCondition() {
        pickerMedicalCondition = UIPickerView()
        pickerMedicalCondition?.dataSource = self
        pickerMedicalCondition?.delegate = self
        pickerMedicalCondition?.tag = TAG_MEDİCAL_CONDİTİON
        
        self.tfMedicalCondition.inputView = pickerMedicalCondition
    }
    
}

extension IntroSecondNewViewController {
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS, sender: self)
    }
}


extension IntroSecondNewViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == TAG_AGE_GROUP {
            return [viewModel.getAgeGroups()].count
        } else {
            return [viewModel.getMedicalConditions()].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == TAG_AGE_GROUP {
            return viewModel.getAgeGroups().count
        } else {
            return viewModel.getMedicalConditions().count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == TAG_AGE_GROUP {
            return viewModel.getAgeGroups()[row]
        } else {
            return viewModel.getMedicalConditions()[row]
        }
    }
    
}
