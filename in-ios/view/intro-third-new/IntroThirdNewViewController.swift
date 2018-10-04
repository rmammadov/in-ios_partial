//
//  IntroThirdNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_HOME = "showHome"

class IntroThirdNewViewController: BaseViewController {

    @IBOutlet weak var viewFirstStep: UIView!
    @IBOutlet weak var viewSecondStep: UIView!
    @IBOutlet weak var viewFourthStep: UIView!
    @IBOutlet weak var viewFifthStep: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setCamera()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setDisabled(sender: Any) {
        let btn = sender as! UIButton
        btn.isEnabled = false
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickBtnForward(_ sender: Any) {
        onContinue()
    }
    
    @IBAction func onClickBtnGetStarted(_ sender: Any) {
        viewFirstStep.isHidden = true
        btnBack.isHidden = true
        viewSecondStep.isHidden = false
    }
    
    @IBAction func onClickBtnRedoFourthStep(_ sender: Any) {
    }
    @IBAction func onClickBtnContinueFourthStep(_ sender: Any) {
        viewFourthStep.isHidden = true
        viewFifthStep.isHidden = false
    }
    
    @IBAction func onClickBtnRedoFifthStep(_ sender: Any) {
    }
    @IBAction func onClickBtn1(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn2(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn3(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn4(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn5(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn6(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn7(_ sender: Any) {
        setDisabled(sender: sender)
        viewSecondStep.isHidden = true
        viewFourthStep.isHidden = false
        btnBack.isHidden = false
        btnForward.isHidden = false
    }
    @IBAction func onClickBtn8(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn9(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn10(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn11(_ sender: Any) {
        setDisabled(sender: sender)
    }
    @IBAction func onClickBtn12(_ sender: Any) {
        setDisabled(sender: sender)
    }
    
    @IBAction func onClickBtn13(_ sender: Any) {
        setDisabled(sender: sender)
    }
}


extension IntroThirdNewViewController {
    
    override func onContinue() {
        super.onContinue()
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_HOME, sender: self)
    }
}

extension IntroThirdNewViewController {
    
    func setCamera()
    {
        // TODO: should be removed and reimplemented after tests
        let cameraManager: CameraManager = CameraManager(cameraView: self.view)
        
        cameraManager.askUserForCameraPermission { (status) in
            if status {
                cameraManager.setPrediction()
                cameraManager.setCamera()
                cameraManager.startSession()
                cameraManager.shouldRespondToOrientationChanges = true
            }
        }
    }
}
