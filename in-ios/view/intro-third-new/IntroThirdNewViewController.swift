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
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBAction func btnStatus(_ sender: Any) {
    }
    @IBOutlet weak var ivProgressbar: UIImageView!
    @IBOutlet weak var ivProgressbarContent: UIImageView!
    @IBOutlet weak var viewFirstStep: UIView!
    @IBOutlet weak var viewSecondStep: UIView!
    @IBOutlet weak var viewThirdStep: UIView!
    @IBOutlet weak var calibrationInProgressView: UIImageView!
    @IBOutlet weak var viewFourthStep: UIView!
    @IBOutlet weak var viewFifthStep: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    
    private let apiHelper = CalibrationApiHelper()
    
    private let viewModel: IntroThirdNewModel = IntroThirdNewModel()
    
    var cameraManager: CameraManager = CameraManager.shared
    let disposeBag = DisposeBag()
    var btnPrevious: UIButton?
    var timerDataCollection: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.status.value = 0
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
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
        startFifthStep()
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
        if navigationController != nil {
            performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_HOME, sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension IntroThirdNewViewController {
    
    func setUi() {
        setSubscribers()
        setViewModel()
    }
    
    func setViewModel() {
       viewModel.setSubscribers()
    }
    
    func updateUi() {
        switch viewModel.getCalibrationStep() {
        case CalibrationStatus.firstStep.rawValue:
            break
        case CalibrationStatus.secondStep.rawValue:
            startSecondStep()
        case CalibrationStatus.thirdStep.rawValue:
            startThirdStep()
        case CalibrationStatus.fourthStep.rawValue:
            startFourthStep()
        case CalibrationStatus.fifthStep.rawValue:
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
                    if self.viewModel.getCalibrationStep() == CalibrationStatus.thirdStep.rawValue {
                        self.handleCalibrationStep()
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.status.asObservable().subscribe(onNext: {
            event in
            if self.viewModel.status.value == CalibrationStatus.loadingCalibrationCompleted.rawValue {
                guard
                    let xModelUrl = self.viewModel.getXModelUrl(),
                    let yModelUrl = self.viewModel.getYModelUrl(),
                    let orientation = self.apiHelper.getCalibrationOrientation()
                    else { return }
                self.cameraManager.updateModels(xModelUrl: URL(string: xModelUrl)!,
                                                yModelUrl: URL(string: yModelUrl)!,
                                                orientation: orientation,
                                                completion: { [weak self] isSuccess in
                                                    DispatchQueue.main.async {
                                                        guard let `self` = self else { return }
                                                        self.viewThirdStep.isHidden = true
                                                        self.viewFifthStep.isHidden = false
                                                        self.btnBack.isHidden = false
                                                        self.btnForward.isHidden = false
                                                    }
                })
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
            
            if viewModel.getCalibrationStep() == CalibrationStatus.secondStep.rawValue {
                timerDataCollection = Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.STANDART_CALIBRATION_STEP_DATA_COLLECTION_DURATION, target: self, selector: #selector(takeScreenShot), userInfo: nil, repeats: false)
                Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.STANDART_CALIBRATION_STEP_DURATION, target: self, selector: #selector(handleCalibrationStep), userInfo: nil, repeats: false)
            } else {
                timerDataCollection = Timer.scheduledTimer(timeInterval: Constant.CalibrationConfig.MOVING_CALIBRATION_STEP_DATA_COLLECTION_DURATION, target: self, selector: #selector(takeScreenShot), userInfo: nil, repeats: true)
                guard let nextBtn = self.view.viewWithTag(viewModel.getNextTag()) else { return }
                let nextBtnAbsoluteFrame = nextBtn.convert((nextBtn.layer.presentation()?.bounds)!, to: self.view)
                AnimationUtil.animateMoving(view: btnPrevious!, moveX: nextBtnAbsoluteFrame.origin.x, moveY: nextBtnAbsoluteFrame.origin.y)
                print("Tag \(tag)")
                print("Previous tag \(viewModel.getNextTag())")
            }
            
        }
    }
    
    @objc func takeScreenShot() {
        DispatchQueue.global(qos: .background).async {
            guard let screenShot = self.cameraManager.takeScreenShot() else { return }
            guard var calibrationDataForFrame = self.cameraManager.getCalibrationFeatures() else { return }
            guard let btn = self.btnPrevious else { return }
            let btnAbsoluteFrame = btn.convert((btn.layer.presentation()?.bounds)!, to: self.view)
            calibrationDataForFrame.cross_x = Float(btnAbsoluteFrame.origin.x)
            calibrationDataForFrame.cross_y = Float(btnAbsoluteFrame.origin.y)
            print("button X: \(String(describing: btn.layer.presentation()?.frame.origin.x))")
            print("button X: \(String(describing: btn.layer.presentation()?.frame.origin.y))")
            self.apiHelper.setCalibrationDataFor(image: screenShot, data: calibrationDataForFrame)
//          viewModel.setCalibrationData(image: screenShot, data: calibrationDataForFrame)
        }
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
        cameraManager.setup(cameraView: view, showPreview: false, showLabel: false, showPointer: false)

        cameraManager.askUserForCameraPermission { (status) in
            guard status else { return }
            self.cameraManager.setCamera()
            self.cameraManager.startSession()
            self.cameraManager.shouldRespondToOrientationChanges = true
            self.cameraManager.updateOrientation()
        }
    }
    
    func setDismissSwipeForSecondStep() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(IntroThirdNewViewController.swiped(_:)))
        swipeGesture.direction = .left
        viewSecondStep.addGestureRecognizer(swipeGesture)
    }
    
    func startThirdStep() {
        viewModel.setCalibrationStep(step: CalibrationStatus.thirdStep.rawValue)
        handleCalibrationStep()
    }
    
    func startNewFourthStep() {
        AnimationUtil.animateLoading(imageView: calibrationInProgressView)
        viewThirdStep.isHidden = false
    }
    
    func startFourthStep() {
        viewSecondStep.isHidden = true
        viewFourthStep.isHidden = false
    }
    
    func startFifthStep() {
        viewFourthStep.isHidden = true
        apiHelper.preparePostProfileOperation()
//        viewModel.postProfileData()
        startNewFourthStep()
    }
    
    @objc func swiped(_ gesture: UIGestureRecognizer) {
        nextStep()
    }
}
