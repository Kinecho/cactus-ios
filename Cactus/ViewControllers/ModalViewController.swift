//
//  ModalViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/30/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {

    var contentView = UIView()
    
    weak var contentVc: UIViewController!
    var contentSize: CGSize?
    
    var contentHeightConstraint: NSLayoutConstraint!
    var contentWidthConstraint: NSLayoutConstraint!        
    var closeButton: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureBlur()
        self.configureContentView()
        self.configureChildContent()
        self.configureCloseButton()
    }
    
    func configureBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.view.insertSubview(blurEffectView, at: 0)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func configureContentView() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.clipsToBounds = true
        self.view.addSubview(self.contentView)
        self.contentView.layer.cornerRadius = 16
        self.contentView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.contentHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: contentSize?.height ?? 350)
        self.contentHeightConstraint.isActive = true
        
        self.contentWidthConstraint = self.contentView.widthAnchor.constraint(equalToConstant: contentSize?.width ?? 250)
        self.contentWidthConstraint.isActive = true
    }
    
    func configureChildContent() {
        guard let vc = self.contentVc else {return}
        vc.willMove(toParent: self)
        self.addChild(vc)
        //
        self.contentView.addSubview(vc.view)

        vc.view.translatesAutoresizingMaskIntoConstraints = false

        vc.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        vc.didMove(toParent: self)

//        if let size = self.contentSize {
//            self.contentHeightConstraint.constant = size.height
//            self.contentWidthConstraint.constant = size.width
//        }
    }
    
    func configureCloseButton() {
        let closeButton = UIButton(frame: CGRect(0, 0, 40, 40))
        
        let closeImage = CactusImage.close.ofWidth(newWidth: 25)?.withRenderingMode(.alwaysTemplate)
        
        closeButton.setImage(closeImage, for: .normal)
        closeButton.imageView?.tintColor = CactusColor.green
        closeButton.backgroundColor = .clear
        closeButton.tintColor = CactusColor.green
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(closeButton)
        closeButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20).isActive = true
        closeButton.addTarget(self, action: #selector(self.dismissModal), for: .primaryActionTriggered)
        self.closeButton = closeButton
    }
    
    @objc func dismissModal() {
        self.dismiss(animated: true)
    }
    
    func setContent(_ vc: UIViewController, size: CGSize? = nil) {
        self.contentVc = vc
        self.contentSize = size
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
