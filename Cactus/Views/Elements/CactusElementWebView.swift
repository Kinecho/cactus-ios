//
//  CactusElementWebView.swift
//  Cactus
//
//  Created by Neil Poulin on 6/1/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import WebKit
class CactusElementWebView: WKWebView {
    var element: CactusElement? {
        didSet {
            self.updateView()
        }
    }
    
    var fileUrl: URL? {
        guard let element = self.element,
            let path = Bundle.main.path(forResource: element.rawValue, ofType: "html") else {
                return nil
        }
        
        return URL(fileURLWithPath: path)
    }
    
    func updateView() {
        self.scrollView.isScrollEnabled = false
        self.isOpaque = false
        self.backgroundColor = .clear
        self.scrollView.backgroundColor = .clear
        
        guard let url = self.fileUrl else {
            self.isHidden = true
            return
        }
        
        self.loadFileURL(url, allowingReadAccessTo: url)
    }
    
    func startAnimation() {
        let js = """
    var el = document.getElementsByClassName("element")[0];
    el.classList.add("running");
"""
        self.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func pauseAnimation() {
        let js = """
        var el = document.getElementsByClassName("element")[0];
        el.classList.remove("running")
    """
        self.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func restartAnimation() {
        //not implemented
    }
}
