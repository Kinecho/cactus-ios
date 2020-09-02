//
//  InsightsWebViewViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 3/5/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import WebKit
class WordBubbleWebViewController: UIViewController {

    var webView: WKWebView!
    let logger = Logger("InsightsWebViewController")
    var activityContainer: UIView?
    var showLoadingIndicatorIfNeeded = false
    var loaded = false
    var unlocked = false
    var chartEnabled = true
    fileprivate var showMeTapped = false
    var showMeEventFired = false
    
    var loading = false {
        didSet {
            self.showActivityIndicator()
        }
    }
    
    var words: [InsightWord]?
    
    /// @Deprecated(since: *, 'Use words instead)
//    var member: CactusMember? {
//        didSet {
//            self.setChartData()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.createWebView()
    }
    
    func createWebView() {
        guard self.isViewLoaded else {
            return
        }
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
        
        webView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        
        self.webView = webView
    }
    
    func buildUrl() -> URL? {
        guard let path = Bundle.main.path(forResource: "wordBubbles", ofType: "html") else {
                self.logger.info("Can not find word bubble page in the bundle")
                return nil
        }
        
        return URL(fileURLWithPath: path)
    }
    
    func loadInsights() {
        guard self.isViewLoaded else {
            return
        }
        guard let url = self.buildUrl() else {
            self.logger.error("Unable to form a valid URL for the insights")
            return
        }
        self.logger.info("Loading web view insights...")
        URLCache.shared.removeAllCachedResponses()

        let r = URLRequest(url: url)
        
        self.webView.load(r)
    }

    func getInsightWordsJSONBase64() -> String? {
//        guard let member = self.member, let wordCloud = member.wordCloud else {
//            return nil
//        }
        guard let wordCloud = self.words else {
            return nil
        }
        
        self.logger.info("Member word cloud is \(String(describing: wordCloud))")
        
        let base64 = try? JSONEncoder().encode(wordCloud).base64EncodedString()
        
        return base64
    }
    
    func showActivityIndicator() {
        if self.loading && self.showLoadingIndicatorIfNeeded {
            self.activityContainer?.removeFromSuperview()
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            self.activityContainer = container
            self.view.addSubview(container)
                      
            container.backgroundColor = .clear
            container.clipsToBounds = true
            container.layer.cornerRadius = 10
            container.widthAnchor.constraint(equalToConstant: 120).isActive = true
            container.heightAnchor.constraint(equalToConstant: 120).isActive = true
            container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = container.bounds
            blurEffectView.clipsToBounds = true
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.insertSubview(blurEffectView, at: 0)
                        
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .fill
              
            container.addSubview(stackView)

            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            stackView.addArrangedSubview(activityIndicator)
            
            let label = UILabel()
            label.text = "Loading Insights"
            label.font = CactusFont.normal(12)
            label.numberOfLines = 0
            label.textColor = CactusColor.textDefault
            stackView.addArrangedSubview(label)
                        
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.activityContainer?.alpha = 0
            }, completion: { _ in
                self.activityContainer?.removeFromSuperview()
            })
        }
    }
    
    func sendShowMeAnalyticsEvent() {
        self.showMeTapped = true
        guard loaded, !showMeEventFired else {
            return
        }
        self.webView.evaluateJavaScript("window.fireShowMeAnalyticsEvent();") { (result, error) in
            guard error == nil else {
                self.logger.error("Failed to evaluate analytics event javascript", error)
                self.showMeEventFired = false //allow it to be fired again
                return
            }
            
            self.logger.info("Unlock insights javascript result \(String(describing: result))")
        }
        self.showMeEventFired = true
    }
    
    ///Un-blur the insights chart
    func unlockInsights() {
        self.unlocked = true
        guard loaded else {
            return
        }
        self.webView.evaluateJavaScript("window.unlockInsights();") { (result, error) in
            guard error == nil else {
                self.logger.error("Failed to evaluate unlock insights javascript", error)
                return
            }
            self.logger.info("Unlock insights javascript result \(String(describing: result))")
        }
    }
    
    ///Blur the insights chart
    func lockInsights() {
        self.unlocked = false
        guard loaded else {
            return
        }
        self.webView.evaluateJavaScript("window.lockInsights();") { (result, error) in
           guard error == nil else {
               self.logger.error("Failed to evaluate lock insights javascript", error)
               return
           }
           self.logger.info("Lock insights javascript result \(String(describing: result))")
       }
    }
    
    func setChartData() {
        guard chartEnabled, loaded, let base64Data = self.getInsightWordsJSONBase64() else {
            return
        }
        
        self.logger.info("Chart bse64 data is:\n\(base64Data)")
        
        self.webView.evaluateJavaScript("window.setInsightWordsBase64(\"\(base64Data)\");") { (result, error) in
            guard error == nil else {
                self.logger.error("Failed to evaluate setInsight word base 64 javascript", error)
                return
            }
            self.logger.info("Set insights javascript result \(String(describing: result))")
        }
    }
}

extension WordBubbleWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loading = false
        self.loaded = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        self.logger.info("Web View loading completed")
        self.setChartData()
        
        if self.unlocked {
            self.unlockInsights()
        }
        
        if self.showMeEventFired {
            self.sendShowMeAnalyticsEvent()
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loading = true
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loading = false
    }        
}
