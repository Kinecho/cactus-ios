//
//  PrivacyPolicyViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/4/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import WebKit
class PrivacyPolicyViewController: UIViewController {

   @IBOutlet weak var webview: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        webview.load(NSURLRequest(url: NSURL(string: "https://cactus.app/privacy-policy?no_nav=true")! as URL) as URLRequest)
        // Do any additional setup after loading the view.
    }
}
