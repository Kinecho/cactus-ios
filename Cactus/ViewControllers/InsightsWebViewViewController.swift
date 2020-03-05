//
//  InsightsWebViewViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 3/5/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import WebKit
class InsightsWebViewViewController: UIViewController {

    var webView: WKWebView!
    let logger = Logger("InsightsWebViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createWebView()
    }
    
    func createWebView() {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        self.view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.webView = webView
    }
    
    func loadInsights() {
        guard let url = URL(string: "https://cactuslocal.ngrok.io/insights-embed") else {
            self.logger.error("Unable to form a valid URL for the insights")
            return
        }
        self.logger.info("Loading web view insights...")
        self.webView.load(URLRequest(url: url))
    }

    func getInsightWordsJSONBase64() -> String? {
        guard let member = CactusMemberService.sharedInstance.currentMember, let wordCloud = member.wordCloud else {
            return "[{word: \"Hello from iOS\", frequency: 1}, {word: \"NoneFound\", frequency: 1.2}]"
        }
        
        self.logger.info("Member word cloud is \(String(describing: wordCloud))")
        
        let base64 = try? JSONEncoder().encode(wordCloud).base64EncodedString()
        
        return base64
    }
}

extension InsightsWebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.showActivityIndicator(show: false)
        self.logger.info("Web View loading completed")
        guard let json = self.getInsightWordsJSONBase64() else {
            return
        }
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        self.webView.evaluateJavaScript("window.setInsightWordsBase64(\"\(json)\");") { (result, error) in
            guard error == nil else {
                self.logger.error("Failed to evaluate javascript", error)
                return
            }
            self.logger.info("Set insights javascript result \(String(describing: result))")
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Set the indicator everytime webView started loading
//        self.showActivityIndicator(show: true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        self.showActivityIndicator(show: false)
    }        
}

