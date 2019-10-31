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
        // Do any additional setup after loading the view.
    }

    func setupView() {
        self.imageContainerView.layer.cornerRadius = self.imageContainerView.bounds.height / 2
//        self.view.layer.cornerRadius = 16
        
        self.elementImage.image = self.element.getImage()
        self.nameTextView.text = self.element.rawValue.capitalized
        self.descriptionTextView.text = self.element.description
        self.closeButton.isHidden = hideCloseButton
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
