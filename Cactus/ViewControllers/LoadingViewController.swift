//
//  LoadingViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/8/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var message: String = "Loading..."
    
    func addAction(_ action: UIView) {
        self.stackView.addArrangedSubview(action)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.text = self.message        
    }
}
