//
//  EditReflectionViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

protocol EditReflectionViewControllerDelegate:class {
    func done(text: String?)
    func cancel()
}

class EditReflectionViewController: UIViewController {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    
    var response: ReflectionResponse!
    var questionText: String?
    var delegate: EditReflectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.questionTextView.text = questionText
        self.responseTextView.text = response.content.text
        
        // Do any additional setup after loading the view.
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("cancel tapped")
        self.delegate?.cancel()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        print("done tapped")
        self.delegate?.done(text: self.responseTextView.text)
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
