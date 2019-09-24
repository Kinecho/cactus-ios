//
//  JournalEntrySkeletonViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/24/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import SkeletonView

class JournalEntrySkeletonViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var responseContainerView: UIView!
    @IBOutlet weak var responseBorderView: UIView!
    @IBOutlet weak var responseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.startSkeleton()
        // Do any additional setup after loading the view.
    }
    
    func configureView() {
        self.responseBorderView.layer.cornerRadius = 6
        self.view.clipsToBounds = true
//        self.responseContainerView.layer.border
    }

    func startSkeleton() {
        self.questionLabel.showAnimatedGradientSkeleton()
        self.dateLabel.showAnimatedGradientSkeleton()
        self.responseLabel.showAnimatedGradientSkeleton()
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
