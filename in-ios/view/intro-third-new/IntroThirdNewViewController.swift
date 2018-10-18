//
//  IntroThirdNewViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import RxSwift

private let SEGUE_IDENTIFIER_SHOW_HOME = "showHome"

class IntroThirdNewViewController: BaseViewController {
    
    @IBOutlet weak var viewFirstStep: UIView!
    @IBOutlet weak var viewSecondStep: UIView!
    @IBOutlet weak var viewFourthStep: UIView!
    @IBOutlet weak var viewFifthStep: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    
    var cameraManager: CameraManager?
    
    private let viewModel: IntroThirdNewModel = IntroThirdNewModel()
    let disposeBag = DisposeBag()
    var btnPrevious: UIButton?
    var timerDataCollection: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUi()
        setCamera()
//        let point = CGPoint(x: self.view.frame.size.height / 2 , y: 0)
//        self.view.hitTest(point, with: nil)
    }
    
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
        setDismissSwipeForSecondStep()
        nextStep()
    }
    
    @IBAction func onClickBtnRedoFourthStep(_ sender: Any) {
    }
    
    @IBAction func onClickBtnContinueFourthStep(_ sender: Any) {
        viewFourthStep.isHidden = true
        viewFifthStep.isHidden = false
        viewModel.postProfileData()
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
    
    func setUi() {
        setSubscribers()
    }
    
    func updateUi() {
        switch viewModel.getCalibrationStep() {
        case CalibrationStep.first.rawValue:
            break
        case CalibrationStep.second.rawValue:
            startSecondStep()
        case CalibrationStep.third.rawValue:
            startThirdStep()
        case CalibrationStep.fourth.rawValue:
            startFourthStep()
        case CalibrationStep.fifth.rawValue:
            break
        default:
            break
        }
    }
    
    func setSubscribers() {
        AnimationUtil.status.asObservable().subscribe(onNext: {
            event in
            if AnimationUtil.status.value == AnimationStatus.completed.rawValue {
                DispatchQueue.main.async {
                    if self.viewModel.getCalibrationStep() == CalibrationStep.third.rawValue {
                        self.handleCalibrationStep()
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func nextStep() {
        viewModel.nextStep()
        updateUi()
    }
    
    func previousStep() {
        viewModel.previousStep()
        updateUi()
    }
    
    func startSecondStep() {
         continueCalibration(tag: viewModel.getTag())
    }
    
    func continueCalibration(tag: Int) {
        if let btnCalibration = self.view.viewWithTag(tag) as? UIButton {
            btnPrevious = btnCalibration
            btnPrevious?.isHidden = false
            
            if viewModel.getCalibrationStep() == CalibrationStep.second.rawValue {
                timerDataCollection = Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.STANDART_CALIBRATION_STEP_DATA_COLLECTION_DURATION, target: self, selector: #selector(takeScreenShot), userInfo: nil, repeats: false)
                Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.STANDART_CALIBRATION_STEP_DURATION, target: self, selector: #selector(handleCalibrationStep), userInfo: nil, repeats: false)
            } else {
                timerDataCollection = Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.MOVING_CALIBRATION_STEP_DATA_COLLECTION_DURATION, target: self, selector: #selector(takeScreenShot), userInfo: nil, repeats: true)
                AnimationUtil.animateMoving(view: btnPrevious!, direction: viewModel.getAnimationType())
            }
            
        }
    }
    
    @objc func takeScreenShot() {
        guard let screenShot = cameraManager?.takeScreenShot() else { return }
        guard var calibrationDataForFrame = cameraManager?.getCalibrationFeatures() else { return }
        guard let btn = btnPrevious else { return }
        calibrationDataForFrame.cross_x = Float((btn.layer.presentation()?.frame.origin.x)!)
        calibrationDataForFrame.cross_y = Float((btn.layer.presentation()?.frame.origin.y)!)
        viewModel.setCalibrationData(image: screenShot, data: calibrationDataForFrame)
    }
    
    @objc func handleCalibrationStep() {
        btnPrevious?.isHidden = true
        timerDataCollection?.invalidate()
        timerDataCollection = nil
        let tag = viewModel.getTag()
        if tag != 0 {
            continueCalibration(tag: tag)
        } else {
            nextStep()
        }
    }
    
    func setCamera() {
        // TODO: should be removed and reimplemented after tests
        cameraManager = CameraManager(cameraView: self.view, showPreview: false, showLabel: false, showPointer: false)
        
        guard let cameraManager = cameraManager else { return }
        
        cameraManager.askUserForCameraPermission { (status) in
            if status {
                cameraManager.setPrediction()
                cameraManager.setCamera()
                cameraManager.startSession()
                cameraManager.shouldRespondToOrientationChanges = true
            }
        }
    }
    
    func setDismissSwipeForSecondStep() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(IntroThirdNewViewController.swiped(_:)))
        swipeGesture.direction = .left
        viewSecondStep.addGestureRecognizer(swipeGesture)
    }
    
    func startThirdStep() {
        viewModel.setCalibrationStep(step: CalibrationStep.third.rawValue)
        handleCalibrationStep()
    }
    
    func startFourthStep() {
        viewSecondStep.isHidden = true
        viewFourthStep.isHidden = false
        btnBack.isHidden = false
        btnForward.isHidden = false
    }
    
    @objc func swiped(_ gesture: UIGestureRecognizer) {
        nextStep()
    }
}
