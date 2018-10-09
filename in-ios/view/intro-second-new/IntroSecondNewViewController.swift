//
//  IntroSecondNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_HOME = "showHome"
private let SEGUE_IDENTIFIER_SHOW_CALIBRATION = "showCalibration"

enum ISVCTextFieldTags: Int {
    case tagName = 10
    case tagGender = 11
    case tagAgeGroup = 12
    case tagMedicalCondition = 13
}

class IntroSecondNewViewController: BaseViewController {
    
    @IBOutlet weak var tfName: INTextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfAgeGroup: INTextField!
    @IBOutlet weak var tfMedicalCondition: INTextField!
    @IBOutlet weak var btnContinue: UIButton!
    
    private var pickerGender: UIPickerView?
    private var pickerAgeGroup: UIPickerView?
    private var pickerMedicalCondition: UIPickerView?
    
    private let viewModel: IntroSecondNewViewModel = IntroSecondNewViewModel()
    
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
        tfName.tag = ISVCTextFieldTags.tagName.rawValue
        tfGender.delegate = self
        tfGender.tag = ISVCTextFieldTags.tagGender.rawValue
        tfAgeGroup.delegate = self
        tfAgeGroup.tag = ISVCTextFieldTags.tagAgeGroup.rawValue
        tfMedicalCondition.delegate = self
        tfMedicalCondition.tag = ISVCTextFieldTags.tagMedicalCondition.rawValue
        self.setKeyboardInetraction()
        
        setPickerGender()
        setPickerAgeGroup()
        setPickerMedicalCondition()
    }
    
    func setPickerGender() {
        pickerGender = UIPickerView()
        pickerGender?.dataSource = self
        pickerGender?.delegate = self
        pickerGender?.tag = ISVCTextFieldTags.tagGender.rawValue
        
        tfGender.inputView = pickerGender
    }
    
    func setPickerAgeGroup() {
        pickerAgeGroup = UIPickerView()
        pickerAgeGroup?.dataSource = self
        pickerAgeGroup?.delegate = self
        pickerAgeGroup?.tag = ISVCTextFieldTags.tagAgeGroup.rawValue
        
        tfAgeGroup.inputView = pickerAgeGroup
    }
    
    func setPickerMedicalCondition() {
        pickerMedicalCondition = UIPickerView()
        pickerMedicalCondition?.dataSource = self
        pickerMedicalCondition?.delegate = self
        pickerMedicalCondition?.tag = ISVCTextFieldTags.tagMedicalCondition.rawValue
        
        tfMedicalCondition.inputView = pickerMedicalCondition
    }
    
    func setValue(tag: Int,  index: Int?, value: String?) {
        switch tag {
        case ISVCTextFieldTags.tagName.rawValue:
            viewModel.setName(name: value)
        case ISVCTextFieldTags.tagGender.rawValue:
            viewModel.setGender(index: index)
        case ISVCTextFieldTags.tagAgeGroup.rawValue:
            viewModel.setAgeGroup(index: index)
        case ISVCTextFieldTags.tagMedicalCondition.rawValue:
            viewModel.setMedicalCondition(index: index)
        default:
            return
        }
    }
    
    func getValues(tag: Int) {
        switch tag {
        case ISVCTextFieldTags.tagName.rawValue:
            tfName.text = viewModel.getName().name
        case ISVCTextFieldTags.tagGender.rawValue:
            tfGender.text = viewModel.getGender().gender
        case ISVCTextFieldTags.tagAgeGroup.rawValue:
            tfAgeGroup.text = viewModel.getAgeGroup().ageGroup
        case ISVCTextFieldTags.tagMedicalCondition.rawValue:
            tfMedicalCondition.text = viewModel.getMedicalCondition().medicalCondition
        default:
            return
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
}

extension IntroSecondNewViewController {
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        getValues(tag: textField.tag)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        setValue(tag: textField.tag, index: nil, value: textField.text)
        getValues(tag: textField.tag)
        
        if !(tfName.text?.isEmpty)! && !(tfGender.text?.isEmpty)! && !(tfAgeGroup.text?.isEmpty)! && !(tfMedicalCondition.text?.isEmpty)! {
            btnContinue.isEnabled = true
        } else {
            btnContinue.isEnabled = false
        }
    }
    
    override func onContinue() {
        super.onContinue()
        viewModel.saveData()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_CALIBRATION, sender: self)
    }
}


extension IntroSecondNewViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == ISVCTextFieldTags.tagGender.rawValue {
            return [viewModel.getGenderOptions()].count
        } else if pickerView.tag == ISVCTextFieldTags.tagAgeGroup.rawValue {
            return [viewModel.getAgeGroups()].count
        } else {
            return [viewModel.getMedicalConditions()].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == ISVCTextFieldTags.tagGender.rawValue {
            return viewModel.getGenderOptions().count
        } else if pickerView.tag == ISVCTextFieldTags.tagAgeGroup.rawValue {
            return viewModel.getAgeGroups().count
        } else {
            return viewModel.getMedicalConditions().count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == ISVCTextFieldTags.tagGender.rawValue {
           return viewModel.getGenderOptions()[row]
        } else if pickerView.tag == ISVCTextFieldTags.tagAgeGroup.rawValue {
            return viewModel.getAgeGroups()[row]
        } else {
            return viewModel.getMedicalConditions()[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setValue(tag: pickerView.tag, index: row, value: nil)
        getValues(tag: pickerView.tag)
    }
    
}
