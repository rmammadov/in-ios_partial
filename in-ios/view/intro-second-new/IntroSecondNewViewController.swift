//
//  IntroSecondNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS = "showGenderOptions"

private let TAG_GENDER = 10
private let TAG_AGE_GROUP = 11
private let TAG_MEDİCAL_CONDİTİON = 12

class IntroSecondNewViewController: BaseViewController {
    
    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfAgeGroup: INTextField!
    @IBOutlet weak var tfMedicalCondition: INTextField!
    
    private var pickerGender: UIPickerView?
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
        tfGender.delegate = self
        tfGender.tag = 1
        tfAgeGroup.delegate = self
        tfAgeGroup.tag = 2
        tfMedicalCondition.delegate = self
        tfMedicalCondition.tag = 3
        self.setKeyboardInetraction()
        
        setPickerGender()
        setPickerAgeGroup()
        setPickerMedicalCondition()
    }
    
    func setPickerGender() {
        pickerGender = UIPickerView()
        pickerGender?.dataSource = self
        pickerGender?.delegate = self
        pickerGender?.tag = TAG_GENDER
        
        tfGender.inputView = pickerGender
    }
    
    func setPickerAgeGroup() {
        pickerAgeGroup = UIPickerView()
        pickerAgeGroup?.dataSource = self
        pickerAgeGroup?.delegate = self
        pickerAgeGroup?.tag = TAG_AGE_GROUP
        
        tfAgeGroup.inputView = pickerAgeGroup
    }
    
    func setPickerMedicalCondition() {
        pickerMedicalCondition = UIPickerView()
        pickerMedicalCondition?.dataSource = self
        pickerMedicalCondition?.delegate = self
        pickerMedicalCondition?.tag = TAG_MEDİCAL_CONDİTİON
        
        tfMedicalCondition.inputView = pickerMedicalCondition
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
        if pickerView.tag == TAG_GENDER {
            return [viewModel.getGenderOptions()].count
        } else if pickerView.tag == TAG_AGE_GROUP {
            return [viewModel.getAgeGroups()].count
        } else {
            return [viewModel.getMedicalConditions()].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == TAG_GENDER {
            return viewModel.getGenderOptions().count
        } else if pickerView.tag == TAG_AGE_GROUP {
            return viewModel.getAgeGroups().count
        } else {
            return viewModel.getMedicalConditions().count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == TAG_GENDER {
           return viewModel.getGenderOptions()[row]
        } else if pickerView.tag == TAG_AGE_GROUP {
            return viewModel.getAgeGroups()[row]
        } else {
            return viewModel.getMedicalConditions()[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == TAG_GENDER {
            tfGender.text = viewModel.getGenderOptions()[row]
        } else if pickerView.tag == TAG_AGE_GROUP {
            tfAgeGroup.text = viewModel.getAgeGroups()[row]
        } else {
            tfMedicalCondition.text = viewModel.getMedicalConditions()[row]
        }
    }
    
}
