//
//  HomeContainerViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 8/8/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

class HomeContainerViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
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

}

extension HomeContainerViewController {
    
    func getParentViewController() -> HomeViewController {
        return self.parent as! HomeViewController
    }
}
