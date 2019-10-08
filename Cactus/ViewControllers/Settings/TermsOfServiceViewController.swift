//
//  TermsOfUseViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import WebKit
class TermsOfUseServiceController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        webview.load(NSURLRequest(url: NSURL(string: "https://cactus.app/terms-of-service?no_nav=true")! as URL) as URLRequest)
        // Do any additional setup after loading the view.
    }
    
}
