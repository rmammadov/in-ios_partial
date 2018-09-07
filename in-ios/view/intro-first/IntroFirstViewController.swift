//
//  IntroFirstViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class IntroFirstViewController: BaseViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelBody: UILabel!
    @IBOutlet weak var btnCheckAgreement: UIButton!
    @IBOutlet weak var btnGetStarted: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBtnCheckAgreement(_ sender: Any) {
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
        self.btnGetStarted.isEnabled = true
    }
    
    @IBAction func onClickBtnGetStarted(_ sender: Any) {
    }
}

extension IntroFirstViewController {
    
    func setUi() {
    }
}
