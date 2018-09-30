//
//  IntroSecondNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/27/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_GENDER_OPTIONS = "showGenderOptions"
private let SEGUE_IDENTIFIER_SHOW_HOME = "showHome"

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
    
    func setValues(tag: Int) {
        switch tag {
        case tfName.tag:
            tfName.text = viewModel.getName()
        case tfGender.tag:
            tfGender.text = viewModel.getGender()
        case tfAgeGroup.tag:
            tfAgeGroup.text = viewModel.getAgeGroup()
        case tfMedicalCondition.tag:
            tfMedicalCondition.text = viewModel.getMedicalCondition()
        default:
            return
        }
    }
    
}

extension IntroSecondNewViewController {
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        setValues(tag: textField.tag)
    }
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_HOME, sender: self)
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
        if pickerView.tag == ISVCTextFieldTags.tagGender.rawValue {
            viewModel.setGender(gender: viewModel.getGenderOptions()[row])
        } else if pickerView.tag == ISVCTextFieldTags.tagAgeGroup.rawValue {
            viewModel.setAgeGroup(ageGroup: viewModel.getAgeGroups()[row])
        } else {
            viewModel.setMedicalCondition(medicalConditon: viewModel.getMedicalConditions()[row])
        }
        
        setValues(tag: pickerView.tag)
    }
    
}
