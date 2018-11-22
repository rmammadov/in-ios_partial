//
//  SettingsInterfaceViewController.swift
//  in-ios
//
//  Created by Piotr Soboń on 21/11/2018.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

class SettingsInterfaceViewController: BaseViewController {
    @IBOutlet weak var languageTextField: INTextField!
    @IBOutlet weak var autoSelectDelayTextField: INTextField!
    @IBOutlet weak var tileSizeTextField: INTextField!
    @IBOutlet weak var soundTextField: INTextField!
    @IBOutlet weak var backButton: GradientButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var viewModel = SettingsInterfaceViewModel()
    private var disposeBag = DisposeBag()
    
    var langPicker: UIPickerView!
    var autoSelectDelayPicker: UIPickerView!
    var tileSizePicker: UIPickerView!
    var soundPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadValues()
        setupUI()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        viewModel.save()
        backButtonTapped(sender)
    }
    
}

extension SettingsInterfaceViewController {
    
    private func setupUI() {
        setupTextField(languageTextField)
        setupTextField(autoSelectDelayTextField)
        setupTextField(tileSizeTextField)
        setupTextField(soundTextField)
        loadValues()
        setKeyboardInetraction()
    }
    
    private func loadValues() {
        let settings = SettingsHelper.shared
        languageTextField.text = settings.language.title
        autoSelectDelayTextField.text = settings.autoSelectDelay.title
        tileSizeTextField.text = settings.tileSize.title
        soundTextField.text = settings.isSoundEnabled ? "on".localized : "off".localized
    }
    
    private func setupTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 6.0
        textField.delegate = self
        var tag: Int
        switch textField {
        case languageTextField:
            tag = SettingsInterfaceViewModel.TextFiledTag.language.rawValue
            preparePicker(for: textField, with: tag)
        case autoSelectDelayTextField:
            tag = SettingsInterfaceViewModel.TextFiledTag.autoSelectDelay.rawValue
            preparePicker(for: textField, with: tag)
        case tileSizeTextField:
            tag = SettingsInterfaceViewModel.TextFiledTag.tileSize.rawValue
            preparePicker(for: textField, with: tag)
        case soundTextField:
            tag = SettingsInterfaceViewModel.TextFiledTag.sound.rawValue
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
        
        let settings = SettingsHelper.shared
        switch tag {
        case SettingsInterfaceViewModel.TextFiledTag.language.rawValue:
            langPicker = picker
            picker.selectRow(Language.allValues.firstIndex(of: settings.language) ?? 0, inComponent: 0, animated: false)
        case SettingsInterfaceViewModel.TextFiledTag.autoSelectDelay.rawValue:
            autoSelectDelayPicker = picker
            picker.selectRow(AutoSelectDelay.allValues.firstIndex(of: settings.autoSelectDelay) ?? 0, inComponent: 0, animated: false)
        case SettingsInterfaceViewModel.TextFiledTag.tileSize.rawValue:
            tileSizePicker = picker
            picker.selectRow(TileSize.allValues.firstIndex(of: settings.tileSize) ?? 0, inComponent: 0, animated: false)
        case SettingsInterfaceViewModel.TextFiledTag.sound.rawValue:
            soundPicker = picker
            picker.selectRow(settings.isSoundEnabled ? 0 : 1, inComponent: 0, animated: false)
        default:
            return
        }
        
        textField.inputView = picker
    }
}

extension SettingsInterfaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case SettingsInterfaceViewModel.TextFiledTag.language.rawValue:
            return Language.allValues.count
        case SettingsInterfaceViewModel.TextFiledTag.autoSelectDelay.rawValue:
            return AutoSelectDelay.allValues.count
        case SettingsInterfaceViewModel.TextFiledTag.tileSize.rawValue:
            return TileSize.allValues.count
        case SettingsInterfaceViewModel.TextFiledTag.sound.rawValue: return 2
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case SettingsInterfaceViewModel.TextFiledTag.language.rawValue:
            return Language.allValues[row].title
        case SettingsInterfaceViewModel.TextFiledTag.autoSelectDelay.rawValue:
            return AutoSelectDelay.allValues[row].title
        case SettingsInterfaceViewModel.TextFiledTag.tileSize.rawValue:
            return TileSize.allValues[row].title
        case SettingsInterfaceViewModel.TextFiledTag.sound.rawValue:
            return row == 0 ? "on".localized : "off".localized
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let settings = SettingsHelper.shared
        switch pickerView.tag {
        case SettingsInterfaceViewModel.TextFiledTag.language.rawValue:
            let value = Language.allValues[row]
            viewModel.selectedLanguage = value
            languageTextField.text = value.title
        case SettingsInterfaceViewModel.TextFiledTag.autoSelectDelay.rawValue:
            let value = AutoSelectDelay.allValues[row]
            viewModel.selectedAutoSelectDelay = value
            autoSelectDelayTextField.text = value.title
        case SettingsInterfaceViewModel.TextFiledTag.tileSize.rawValue:
            let value = TileSize.allValues[row]
            viewModel.selectedTileSize = value
            tileSizeTextField.text = value.title
        case SettingsInterfaceViewModel.TextFiledTag.sound.rawValue:
            let value = row == 0
            viewModel.isSoundEnabled = value
            settings.isSoundEnabled = value
            soundTextField.text = value ? "on".localized : "off".localized
        default: return
        }
    }
}
