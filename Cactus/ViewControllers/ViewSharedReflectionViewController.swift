//
//  ViewSharedReflectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 11/16/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class ViewSharedReflectionViewController: UIViewController {
    @IBOutlet weak var noteContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    var reflectionVc: SharedReflectionViewController?
    var promptContent: PromptContent?
    var memberProfile: MemberProfile?
    
    var reflectionResponse: ReflectionResponse!
    var logger = Logger("ViewSharedReflectionViewController")
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureResponse()
    }

    func configureResponse() {
        self.embedSharedReflection()
    }
    
    func embedSharedReflection() {
        if self.reflectionVc == nil {
            let vc =  SharedReflectionViewController.loadFromNib()
            self.reflectionVc = vc
            vc.willMove(toParent: self)
            self.addChild(vc)
        } else {
            logger.info("Reflection View already set up")
        }
        
        guard let vc = self.reflectionVc else {
            logger.warn("No reflectionVc found, can't continue")
            return
        }
        
        vc.reflectionResponse = self.reflectionResponse
        vc.promptContent = self.promptContent
        vc.authorProfile = self.memberProfile
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.noteContainerView.addSubview(vc.view)
        self.noteContainerView.layer.cornerRadius = 10
        vc.view.leadingAnchor.constraint(equalTo: self.noteContainerView.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: self.noteContainerView.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: self.noteContainerView.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.noteContainerView.bottomAnchor).isActive = true
        self.didMove(toParent: self)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    } 
}
