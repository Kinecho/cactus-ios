//
//  VideoContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/6/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import WebKit
class VideoContentViewController: PromptContentViewController {
    @IBOutlet weak var videoWebKitView: WKWebView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mainStackView: UIStackView!
    var lastCardButton: UIButton?
    
    let videoLogger = Logger("VideoContentViewController")
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }

    func setupViews() {
        self.configureText()
        self.configureVideo()
        
        if let contentLink = self.createContentLink() {
            self.mainStackView.addArrangedSubview(contentLink)
        }
    }
    
    func configureVideo() {
        if let youtubeId = content.video?.youtubeVideoId, let url = URL(string: "https://www.youtube.com/embed/\(youtubeId)") {
            self.videoLogger.debug("Youtube id is \(youtubeId)")
            let request = URLRequest(url: url)
            self.videoWebKitView.load(request)
            self.videoWebKitView.isHidden = false
        } else {
            self.videoLogger.warn("Unable to get youtube video")
            self.videoWebKitView.isHidden = true
        }
    }
    
    func configureText() {
        if let textContent = self.content.text_md ?? self.content.text {
            let mdText = MarkdownUtil.centeredMarkdown(textContent, font: CactusFont.normal(32), color: CactusColor.textDefault)
            self.textView.attributedText = mdText
            self.textView.isHidden = false
        } else {
            self.textView.text = nil
            self.textView.attributedText = nil
            self.textView.isHidden = true
        }
        
        self.lastCardButton?.removeFromSuperview()
        if let lastCardButton = self.getLastCardDoneButton() {
            self.lastCardButton = lastCardButton
            self.mainStackView.addArrangedSubview(lastCardButton)
        }
    }
}
