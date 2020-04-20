//
//  CoreValuesAssessmentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import WebKit

class CoreValuesAssessmentViewController: UIViewController {
    
    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!
    let logger = Logger("CoreValuesAssessmentViewController")
    var member: CactusMember?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.member = CactusMemberService.sharedInstance.currentMember
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "showPricing")
        contentController.add(self, name: "appMounted")

        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = contentController
        let webView = WKWebView(frame: webViewContainer.frame, configuration: webViewConfig)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor).isActive = true
        self.webView = webView
        
        guard let url = URL(string: "\(CactusConfig.webDomain)/core-values?embed=true") else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    func registerAppWithWeb() {
        let tier = self.member?.tier.rawValue ?? ""
        let name = self.member?.firstName ?? ""
        let memberId = self.member?.id ?? ""
        self.webView.evaluateJavaScript("CactusIosDelegate.register(\"\(memberId)\", \"\(name)\", \"\(tier)\")", completionHandler: nil)
    }

}

extension CoreValuesAssessmentViewController: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.logger.info("User content controller recieved message \(message.name)")
        if message.name == "showPricing" {
            let pricingVc = ScreenID.Pricing.getViewController()
            NavigationService.sharedInstance.present(pricingVc, animated: true)
        }
        
        if message.name == "appMounted" {
            self.registerAppWithWeb()
        }
        
        guard let jsonString = message.body as? String else {
            return
        }
        
        self.logger.info("core values \(message.name) string \(jsonString)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           // Set the indicator everytime webView started loading
        self.logger.info("Started loading")
//           self.showActivityIndicator(show: true)
//           self.backButton.isEnabled = webView.canGoBack
//           self.forwardButton.isEnabled = webView.canGoForward
       }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      //This function is called when the webview finishes navigating to the webpage.
      //We use this to send data to the webview when it's loaded.
//        self.sendAssessmentResponseToWeb()        
//        sleep(1)
//        self.registerAppWithWeb()
    }
    
}
