//
//  HomeViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 7/10/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit

private let segueIdentifier = "segueSubMenu"

class HomeViewController: BaseViewController {

    @IBOutlet weak var collectionTopMenu: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var containerViewSubMenu: UIView!
    
    fileprivate let viewModel = HomeViewModel()
    
    fileprivate var vcSubMenu: SubMenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationBar()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let vc = segue.destination as? SubMenuViewController {
                self.vcSubMenu = vc
            }
        }
    }
}

extension HomeViewController {
    
    func setupViewModel() {
        self.viewModel.setSubscribers()
        self.viewModel.getMenuItems()
    }
}
