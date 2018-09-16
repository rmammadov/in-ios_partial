//
//  IntroFifthViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_HOME = "showHome"

class IntroFifthViewController: BaseViewController {

    @IBOutlet weak var tfMedicalCondition: UITextField!
    
    private var pickerMedicalCondition: UIPickerView?
    private let viewModel: IntroFifthViewModel = IntroFifthViewModel()
    
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
    
    @IBAction func onClickContinueBtn(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_HOME, sender: self)
    }
    
}

extension IntroFifthViewController {
    
    func setUi() {
        setPicker()
        self.setKeyboardInetraction()
    }
    
    func setPicker() {
        pickerMedicalCondition = UIPickerView()
        pickerMedicalCondition?.dataSource = self
        pickerMedicalCondition?.delegate = self
        
        self.tfMedicalCondition.inputView = pickerMedicalCondition
        self.tfMedicalCondition.text = viewModel.getMedicalConditions().first
    }
}

extension IntroFifthViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return [viewModel.getMedicalConditions()].count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getMedicalConditions().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getMedicalConditions()[row]
    }
    
}
