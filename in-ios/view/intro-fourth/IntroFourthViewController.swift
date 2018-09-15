//
//  IntroFourthViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/15/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_MEDICAL_INPUT = "showMedicalInput"

class IntroFourthViewController: BaseViewController {
    
    @IBOutlet weak var tfAgeGroup: UITextField!
    
    private var pickerAgeGroup: UIPickerView?

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
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_MEDICAL_INPUT, sender: self)
    }
    
}

extension IntroFourthViewController {
    
    func setUi() {
        setPicker()
        self.setKeyboardInetraction()
    }
    
    func setPicker() {
        pickerAgeGroup = UIPickerView()
        pickerAgeGroup?.dataSource = self
        pickerAgeGroup?.delegate = self
        
        self.tfAgeGroup.inputView = pickerAgeGroup
    }
}

extension IntroFourthViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
}
