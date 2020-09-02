//
//  CactusElementsViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class CactusElementsViewController: PromptContentViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var energyImage: UIImageView!
    @IBOutlet weak var experienceImage: UIImageView!
    @IBOutlet weak var relationshipsImage: UIImageView!
    @IBOutlet weak var emotionsImage: UIImageView!
    @IBOutlet weak var meaningImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = self.content.text
        
        self.energyImage.isUserInteractionEnabled = true
        self.energyImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.energySelected)))
        
        self.meaningImage.isUserInteractionEnabled = true
        self.meaningImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.meaningSelected)))
        
        self.experienceImage.isUserInteractionEnabled = true
        self.experienceImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.experienceSelected)))
        
        self.relationshipsImage.isUserInteractionEnabled = true
        self.relationshipsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.relationshipsSelected)))
        
        self.emotionsImage.isUserInteractionEnabled = true
        self.emotionsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.emotionsSelected)))
        
        // Do any additional setup after loading the view.
    }
    
    @objc func energySelected() {
        self.showModal(.energy)
    }
    
    @objc func meaningSelected() {
        self.showModal(.meaning)
    }
    
    @objc func experienceSelected() {
        self.showModal(.experience)
    }
    
    @objc func emotionsSelected() {
        self.showModal(.emotions)
    }
    
    @objc func relationshipsSelected() {
        self.showModal(.relationships)
    }

    @objc func dismissModal() {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showModal(_ element: CactusElement) {
        guard let contentVc = ScreenID.elementsPageView.getViewController() as? CactusElementPageViewController else {return}
        let modalVc = ModalViewController()
        modalVc.setContent(contentVc, size: CGSize(width: 250, height: 350))
        contentVc.backgroundColor = NamedColor.MenuBackground.uiColor
        contentVc.initialElement = element
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
        
        self.present(modalVc, animated: true)

    }
    
    func oldshowModal(image: UIImage?, name: String, text: String) {
        let modal = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
                
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        content.backgroundColor = CactusColor.darkestGreen
        modal.addSubview(content)
        content.layer.cornerRadius = 16
        content.widthAnchor.constraint(equalToConstant: 280).isActive = true
        content.heightAnchor.constraint(equalToConstant: 300).isActive = true
        content.centerYAnchor.constraint(equalTo: modal.centerYAnchor).isActive = true
        content.centerXAnchor.constraint(equalTo: modal.centerXAnchor).isActive = true
//        modal.leadingAnchor.constraint(equalTo: modal.leadingAnchor, constant: 20)
                
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = CactusColor.pink
        imageView.clipsToBounds = true
                
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.sizeThatFits(CGSize(70, 70))
        content.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: content.topAnchor, constant: 40).isActive = true
        imageView.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
        
        let typeLabel = UITextView()
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(typeLabel)
        typeLabel.text = name
        typeLabel.isScrollEnabled = false
        typeLabel.backgroundColor = .clear
        typeLabel.isEditable = false
        typeLabel.textAlignment = .center
        typeLabel.textColor = .white
        typeLabel.font = CactusFont.bold(20)
        typeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20 ).isActive = true
        typeLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20 ).isActive = true
        typeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20 ).isActive = true
        
        let textView = UITextView()
        textView.text = text
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textAlignment = .center
        textView.textColor = CactusColor.lightBlue
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20 ).isActive = true
        textView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20 ).isActive = true
        textView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 0 ).isActive = true
        textView.font = CactusFont.normal
        
        let closeButton = UIButton(frame: CGRect(0, 0, 40, 40))
        let closeImage = CactusImage.close.ofWidth(newWidth: 25)?.withRenderingMode(.alwaysTemplate)
        
        closeButton.setImage(closeImage, for: .normal)
        closeButton.imageView?.tintColor = CactusColor.green
        closeButton.backgroundColor = .clear
        closeButton.tintColor = CactusColor.green
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(closeButton)
        closeButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20).isActive = true
        closeButton.topAnchor.constraint(equalTo: content.topAnchor, constant: 20).isActive = true
        closeButton.addTarget(self, action: #selector(self.dismissModal), for: .primaryActionTriggered)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = modal.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        modal.insertSubview(blurEffectView, at: 0)
//        modal.backgroundColor = .blue
        let modalVc = UIViewController()
        modalVc.view = modal
        
//        modal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissModal)))
        
        modalVc.modalPresentationStyle = .overCurrentContext
        modalVc.modalTransitionStyle = .crossDissolve
                
        self.present(modalVc, animated: true)
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
