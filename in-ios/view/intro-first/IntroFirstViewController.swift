//
//  IntroFirstViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 9/3/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let SEGUE_IDENTIFIER_SHOW_NAME_INPUT = "showNameSurnameInput"

class IntroFirstViewController: BaseViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelBody: UILabel!
    @IBOutlet weak var btnCheckAgreement: UIButton!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var tvAgreement: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
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
        performSegue(withIdentifier: SEGUE_IDENTIFIER_SHOW_NAME_INPUT, sender: self)
    }
}

extension IntroFirstViewController {
    
    func setUi() {
        setAgreement()
    }
}

extension IntroFirstViewController: UITextViewDelegate {
    
    func setAgreement() {
        self.tvAgreement.delegate = self
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.white
        attributes[.underlineColor] = UIColor.white
        attributes[.font] = UIFont(name: "Avenir Next Medium", size: 12.0)!
        
        let attributedString = NSMutableAttributedString(string: "I agree to the Privacy Policy and Terms and Conditions", attributes: attributes)
        
        let rangePrivacy = attributedString.mutableString.range(of: "Privacy Policy")
        let rangeTerms = attributedString.mutableString.range(of: "Terms and Conditions")
        
        attributedString.addAttribute(.link, value: "https://www.google.com", range: rangePrivacy)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: 1), range: rangePrivacy)
        
        attributedString.addAttribute(.link, value: "https://www.apple.com", range: rangeTerms)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: 1), range: rangeTerms)
        
        self.tvAgreement.attributedText = attributedString
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        
        return false
    }
    
}
