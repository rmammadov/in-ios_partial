//
//  SettingsAccountViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SettingsAccountViewController: BaseViewController {
    @IBOutlet weak var nameTextField: INTextField!
    @IBOutlet weak var genderTextField: INTextField!
    @IBOutlet weak var ageTextField: INTextField!
    @IBOutlet weak var medicalConditionTextField: INTextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: GradientButton!
    
    
    var viewModel = SettingsAccountViewModel()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadValues()
        setupUI()
        setSubscribers()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.saveData()
        backButtonTapped(sender)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        guard let textField = sender as? UITextField else { return }
        if textField == nameTextField {
            viewModel.name = textField.text!
        }
        viewModel.validateForm()
    }
    
}

extension SettingsAccountViewController {
    
    private func setupUI() {
        setupTextField(nameTextField)
        setupTextField(genderTextField)
        setupTextField(ageTextField)
        setupTextField(medicalConditionTextField)
        loadValues()
        setKeyboardInetraction()
    }
    
    private func setSubscribers() {
        viewModel.getValidationObserver().subscribe(onNext: { (isValid) in
            self.saveButton.isEnabled = isValid
        }).disposed(by: disposeBag)
    }
    
    private func loadValues() {
        guard let userData = viewModel.loadData() else { return }
        nameTextField.text = userData.name
        genderTextField.text = userData.gender
        ageTextField.text = userData.ageGroup
        medicalConditionTextField.text = userData.medicalCondition
    }
    
    private func setupTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 6.0
        textField.delegate = self
        var tag: Int
        switch textField {
        case nameTextField:
            tag = ISVCTextFieldTags.tagName.rawValue
        case genderTextField:
            tag = ISVCTextFieldTags.tagGender.rawValue
            preparePicker(for: textField, with: tag)
        case ageTextField:
            tag = ISVCTextFieldTags.tagAgeGroup.rawValue
            preparePicker(for: textField, with: tag)
        case medicalConditionTextField:
            tag = ISVCTextFieldTags.tagMedicalCondition.rawValue
            preparePicker(for: textField, with: tag)
        default:
            return
        }
        textField.tag = tag
        
    }
    
    func preparePicker(for textField: UITextField, with tag: Int) {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.tag = tag
        
        textField.inputView = picker
    }
}

extension SettingsAccountViewController {
    
}

extension SettingsAccountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case ISVCTextFieldTags.tagGender.rawValue:
            return viewModel.genders.count
        case ISVCTextFieldTags.tagAgeGroup.rawValue:
            return viewModel.ages.count
        case ISVCTextFieldTags.tagMedicalCondition.rawValue:
            return viewModel.medicalConditions.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case ISVCTextFieldTags.tagGender.rawValue:
            return viewModel.genders[row]
        case ISVCTextFieldTags.tagAgeGroup.rawValue:
            return viewModel.ages[row]
        case ISVCTextFieldTags.tagMedicalCondition.rawValue:
            return viewModel.medicalConditions[row]
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case ISVCTextFieldTags.tagGender.rawValue:
            let text = viewModel.genders[row]
            viewModel.gender = text
            genderTextField.text = text
        case ISVCTextFieldTags.tagAgeGroup.rawValue:
            let text = viewModel.ages[row]
            viewModel.age = text
            ageTextField.text = text
        case ISVCTextFieldTags.tagMedicalCondition.rawValue:
            let text = viewModel.medicalConditions[row]
            viewModel.medicalCondition = text
            medicalConditionTextField.text = text
        default: return
        }
        viewModel.validateForm()
    }
}
