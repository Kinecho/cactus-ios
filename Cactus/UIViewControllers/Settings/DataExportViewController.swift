//
//  DataExportViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 4/9/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

class DataExportViewController: UIViewController {
    
    @IBOutlet weak var emailMeButton: PrimaryButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var inputErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailFormStackView: UIStackView!
    @IBOutlet weak var emailDescriptionLabel: UILabel!
    @IBOutlet weak var downloadButton: SecondaryButton!
    
    var showEmail: Bool = false {
        didSet {
            self.configureEmailForm()
        }
    }
    let logger = Logger("DataExportViewController")
    var member: CactusMember?
    var sendToEmail: String? {
        self.emailTextField.text
    }
    
    var exportResult: DataExportResult? {
        didSet {
            self.updateResultInfo()
        }
    }
    
    var downloadUrl: String? {
        return self.exportResult?.downloadUrl
    }
    
    var hasLoaded: Bool {
        return self.exportResult != nil
    }
    
    var loading: Bool = false {
        didSet {
            self.updateLoadingState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.member = CactusMemberService.sharedInstance.currentMember
        self.loadingStackView.isHidden = true
        self.inputErrorLabel.isHidden = true
        // Do any additional setup after loading the view.
        self.resultLabel.isHidden = true
        self.configureEmailForm()
        //self.emailMeButton.setTitle("Processing...", for: .disabled)
        //        self.createExportButton.disabledBackgroundColor = CactusColor.gray
        self.view.setupKeyboardDismissRecognizer()
    }
    
    func updateLoadingState() {
        self.emailMeButton.setEnabled(!self.loading && !self.hasLoaded)
        self.emailMeButton.isHidden = self.loading || self.hasLoaded
        self.loadingStackView.isHidden = !self.loading
        self.downloadButton.isHidden = self.loading
    }
    
    func configureEmailForm() {
        guard self.isViewLoaded else {
            return
        }
        self.emailFormStackView.isHidden = !self.showEmail
        if self.showEmail {
            self.emailTextField.text = self.member?.email ?? ""
            self.emailMeButton.setTitle("Send", for: .normal)
            self.downloadButton.isHidden = true
        } else {
            self.emailMeButton.setTitle("Email Me", for: .normal)
        }
    }
    
    func updateResultInfo() {
        guard let result = self.exportResult else {
            return
        }
        DispatchQueue.main.async {
            if result.success {
                self.resultLabel.text = self.showEmail ? "Next, check your \(self.sendToEmail ?? "") email account for a link to download your data. "
                    + "You can also download it now to this device." : nil
                self.emailMeButton.isHidden = self.showEmail
                self.downloadButton.isHidden = false
                self.resultLabel.isHidden = !self.showEmail
                self.emailFormStackView.isHidden = true
            } else {
                self.resultLabel.text = "Your data export was unable to be processed right now. Please try again later."
                self.downloadButton.isHidden = true
                self.resultLabel.isHidden = false
            }
        }
    }
    
    @IBAction func emailMeTapped(_ sender: Any) {
        self.logger.info("tapped create export button")
        if self.showEmail {
            self.createExport(sendEmail: true)
        } else {
            self.showEmail = true
        }
    }
    
    func showInputError(_ show: Bool) {
        self.inputErrorLabel.text = "Please enter a valid email."
        self.inputErrorLabel.isHidden = !show
    }
    
    func createExport(sendEmail: Bool, openOnComplete: Bool = false) {
        if sendEmail && !isValidEmail(self.sendToEmail) {
            self.showInputError(true)
            return
        } else {
            self.showInputError(false)
        }
        let params = DataExportParams(sendEmail: sendEmail, email: self.sendToEmail)
        self.loading = true
        UserService.sharedInstance.createDataExport(params) { (result) in
            DispatchQueue.main.async {
                self.logger.info("Result: \(result)")
                self.loading = false
                self.exportResult = result
                
                if openOnComplete, let downloadUrl = result.downloadUrl, let url = URL(string: downloadUrl) {
                    NavigationService.shared.openUrl(url: url)
                }
            }
        }
    }
    
    @IBAction func downloadTapped(_ sender: Any) {
        guard let downloadUrl = self.downloadUrl, let url = URL(string: downloadUrl) else {
            self.createExport(sendEmail: false, openOnComplete: true)
            return
        }
        NavigationService.shared.openUrl(url: url)
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
