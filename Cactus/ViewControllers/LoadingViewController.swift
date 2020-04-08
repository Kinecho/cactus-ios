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
    
    var message: String = "Loading..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageLabel.text = self.message

        // Do any additional setup after loading the view.
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
