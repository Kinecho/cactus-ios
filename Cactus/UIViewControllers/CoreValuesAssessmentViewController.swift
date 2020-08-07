//
//  CoreValuesAssessmentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit
import WebKit
import FirebaseFirestore
class CoreValuesAssessmentViewController: UIViewController {
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var webViewContainer: UIView!
    var loadingVc: LoadingViewController?
    var webView: WKWebView!
    let logger = Logger("CoreValuesAssessmentViewController")
    
    var memberUnsubscriber: Unsubscriber?
    
    var member: CactusMember? {
        didSet {
            self.handleMemberUpdated()
        }
    }
    var showTopNavbar: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.topToolbar.isHidden = !self.showTopNavbar
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.member = self.member ?? CactusMemberService.sharedInstance.currentMember
        self.memberUnsubscriber = CactusMemberService.sharedInstance.observeCurrentMember { (member, _, _) in
            self.member = member ?? self.member
        }
        
        let settings = AppSettingsService.sharedInstance.currentSettings
        let contentController = WKUserContentController()
        contentController.registerMessageHandlers(with: self)
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = contentController
        let webView = WKWebView(frame: webViewContainer.frame, configuration: webViewConfig)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.customUserAgent = "CactusIos"
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor).isActive = true
        self.webView = webView
                
        self.topToolbar.isHidden = !self.showTopNavbar && !self.isBeingPresented
        
        guard let url = URL(string: "\(CactusConfig.webDomain)\(settings?.coreValuesPath ?? "/core-values/embed")") else {
            return
        }
        logger.info("Loading core values url \(url.absoluteString)")
        webView.load(URLRequest(url: url))
    }
    
    deinit {
        self.memberUnsubscriber?()
    }
    
    func showLoadingIndicator() {
        guard let loadingVc = self.loadingVc ?? ScreenID.LoadingFullScreen.getViewController() as? LoadingViewController else {
            return
        }
        self.addChild(loadingVc)
        loadingVc.view.frame = self.webView.frame
        self.webView.addSubview(loadingVc.view)
        loadingVc.didMove(toParent: self)
        self.loadingVc = loadingVc
    }
    
    func removeLoadingIndicator() {
        self.loadingVc?.willMove(toParent: nil)
        self.loadingVc?.view.removeFromSuperview()
        self.loadingVc?.removeFromParent()
        
    }
    
    func handleMemberUpdated() {
        guard self.isViewLoaded else {
            return
        }

        self.updateMemberInfoWithWeb()
    }
    
    func updateMemberInfoWithWeb() {
        let tier = self.member?.tier.rawValue ?? ""
        let name = self.member?.firstName ?? ""
        let memberId = self.member?.id ?? ""
        self.webView?.evaluateJavaScript("CactusIosDelegate.updateMember(\"\(memberId)\", \"\(name)\", \"\(tier)\");", completionHandler: nil)
    }
    
    func registerAppWithWeb() {
        self.topToolbar.isHidden = true
        let tier = self.member?.tier.rawValue ?? ""
        let name = self.member?.firstName ?? ""
        let memberId = self.member?.id ?? ""
        self.webView.evaluateJavaScript("CactusIosDelegate.register(\"\(memberId)\", \"\(name)\", \"\(tier)\");", completionHandler: nil)
    }

    @IBAction func toolbarDoneTapped(_ sender: Any) {
        //todo: detect if the assessment is in progress and show a warning
        self.closeCoreValues()
    }
    
    func closeCoreValues() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }        
    }
    
    func onPricingClosed() {
        logger.info("Pricing closed")
        self.updateMemberInfoWithWeb()
    }
}

extension CoreValuesAssessmentViewController: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.logger.info("User content controller recieved message \(message.name)")
        
        guard let handler = WebkitMessageHandler.init(rawValue: message.name) else {
            logger.error("Unable to process message handler - name \"\(message.name)\" not supported")
            return
        }
        switch handler {
        case .appMounted:
            self.registerAppWithWeb()
        case .closeCoreValues:
            self.logger.info("Closing core values")
            self.closeCoreValues()
        case .showPricing:
            guard let pricingVc = ScreenID.Pricing.getViewController() as? PricingViewController else {
                return
            }
            pricingVc.titleOvereride = "Get your quiz results with Cactus Plus"
            pricingVc.subTitleOverride = "Try it free and get daily prompts, personal insights and more"
            pricingVc.onDismiss = {
                self.onPricingClosed()
            }
            pricingVc.modalPresentationStyle = .overCurrentContext
            NavigationService.shared.present(pricingVc, animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.logger.info("Started loading")
        self.showLoadingIndicator()
   }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.removeLoadingIndicator()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.logger.error("Failed to load webpage", error)
    }
}
