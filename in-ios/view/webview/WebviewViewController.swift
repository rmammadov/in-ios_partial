//
//  WebViewController.swift
//  in-ios
//
//  Created by Rahman Mammadov on 10/1/18.
//  Copyright © 2018 com.innodemneurosciences. All rights reserved.
//

import UIKit
import WebKit

class WebviewViewController: BaseViewController {

    @IBOutlet weak var webView: WKWebView!
    
    let viewModel: WebviewViewModel = WebviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideNavigationBar()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WebviewViewController {
    
    func setUi() {
        setWebView()
    }
    
    func setWebView() {
        self.webView.allowsBackForwardNavigationGestures = false
        guard let htmlString = viewModel.getHtml() else { return }
        self.webView.loadHTMLString(htmlString, baseURL: nil)
    }
}
