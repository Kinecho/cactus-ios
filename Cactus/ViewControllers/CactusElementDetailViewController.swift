//
//  CactusElementModalViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/30/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class CactusElementDetailViewController: UIViewController {

    @IBOutlet weak var elementImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var imageContainerView: UIView!
    
    var hideCloseButton: Bool = false
    
    var element: CactusElement!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    func setupView() {
        self.imageContainerView.layer.cornerRadius = self.imageContainerView.bounds.height / 2
        self.elementImage.tintColor = self.element.color
        self.elementImage.image = self.element.getImage()
        self.nameTextView.text = self.element.rawValue.capitalized
        self.descriptionTextView.text = self.element.description
        self.closeButton.isHidden = hideCloseButton
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
