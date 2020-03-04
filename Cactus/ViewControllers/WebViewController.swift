//
//  WebViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 3/4/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var url: URL?
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.navigationDelegate = self
        self.configureView()
        self.loadContent()
    }
    
    func configureView() {
        self.activityContainer.layer.cornerRadius = 10
        self.activityContainer.clipsToBounds = true
        self.activityContainer.backgroundColor = UIColor.clear
        self.activityIndicator.color = CactusColor.white
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.activityContainer.insertSubview(blurEffectView, at: 0)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.leadingAnchor.constraint(equalTo: self.activityContainer.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: self.activityContainer.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: self.activityContainer.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.activityContainer.bottomAnchor).isActive = true
    }
    
    func loadUrl(string: String) {
        self.url = URL(string: string)
        self.loadContent()
    }
    
    func loadUrl(url: URL?) {
        self.url = url
        self.loadContent()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadContent() {
        guard let url = self.url else {
            return
        }
        self.webView.load(URLRequest(url: url))
    }
    fileprivate func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
            activityContainer.isHidden = false
        } else {
            activityIndicator.stopAnimating()
            activityContainer.isHidden = true
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.showActivityIndicator(show: false)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Set the indicator everytime webView started loading
        self.showActivityIndicator(show: true)
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showActivityIndicator(show: false)
    }
}
