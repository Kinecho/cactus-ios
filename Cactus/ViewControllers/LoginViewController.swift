//
//  LoginViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class LoginViewController: UIViewController {
    var authUI: FUIAuth!
    var loggedOutTitle = "Sign In"
    var anonymousUserTitle = "Create an Account"
    var anonymousSubtitle = "Start with a happier mindset toady."
    var loggedOutSubtitle = "Start with a happier mindset today."
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var otherProviderLabel: UILabel!
    @IBOutlet weak var emailInputView: CactusTextInputField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var submitEmailButton: PrimaryButton!
    var authViewController: UIViewController?
    
    var authHandler: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.authHandler = AuthService.sharedInstance.getAuthStateChangeHandler { (_, user) in
            self.configureUI(user)
        }
        self.emailInputView.attributedPlaceholder = NSAttributedString(string: "Enter your email address").withColor(CactusColor.darkText)
        self.view.setupKeyboardDismissRecognizer()
        self.emailInputView.delegate = self
    }
    
    deinit {
        AuthService.sharedInstance.removeAuthStateChangeListener(self.authHandler)
    }
    
    @IBAction func magicLinkNext(_ sender: Any) {
        let email = self.emailInputView.text
        self.submitMagicLinkEMail(email)
    }
    
    func showInvalidEmail() {
        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitMagicLinkEMail(_ email: String?) {
        self.submitEmailButton.setEnabled(false)
        self.submitEmailButton.setTitle("Submitting...", for: .disabled)
        guard let email = email?.trimmingCharacters(in: .whitespacesAndNewlines),
            isValidEmail(email) else {
            self.showInvalidEmail()
            self.submitEmailButton.setEnabled(true)
            return
        }
        
        print("submitting magic link \(email)")
        UserDefaults.standard.set(email, forKey: "MagicLinkEmail")
        let magicLinkRequest = MagicLinkRequest(email: email, continuePath: "/home")
        ApiService.sharedInstance.sendMagicLink(magicLinkRequest) { (response) in
            DispatchQueue.main.async {
                print("Got magic link ")
                self.submitEmailButton.setEnabled(true)
                self.handleMagicLinkResponse(response)
            }            
        }
    }
    
    func handleMagicLinkResponse(_ magicLinkResponse: MagicLinkResponse) {
        let greeting = magicLinkResponse.exists ? "Welcome Back!" : "Welcome!"
        let alert = UIAlertController(title: greeting, message: "An email has been sent to \(magicLinkResponse.email).", preferredStyle: .alert)
        if magicLinkResponse.success == false {
            alert.title = "Oops! Something's not right."
            alert.message = magicLinkResponse.error ?? "Something unexpected happened. Please try again later"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func configureUI(_ user: User?=AuthService.sharedInstance.getCurrentUser()) {
        self.configureAuth(user)
        if let user = user {
            if !user.isAnonymous {
                showLoggedInUI(user)
            } else {
                showAnonymousUserUI(user)
            }
        } else {
            showLoggedOutUI()
        }
    }
    
    func showAnonymousUserUI(_ user: User) {
        self.titleLabel.text = anonymousUserTitle
        self.subTextLabel.text = anonymousSubtitle
        self.titleLabel.isHidden = false
        self.subTextLabel.isHidden = false
        self.configureAuthView()
    }
    
    func showLoggedOutUI() {
        self.titleLabel.text = loggedOutTitle
        self.subTextLabel.text = loggedOutSubtitle
        self.titleLabel.isHidden = false
        self.subTextLabel.isHidden = false
        self.emailInputView.isHidden = false
        self.submitEmailButton.isHidden = false
        self.otherProviderLabel.isHidden = false
        self.configureAuthView()
    }
    
    func showLoggedInUI(_ user: User) {
        self.removeAuthViewController()
//        self.titleLabel.text = user.email
        self.titleLabel.isHidden = true
        self.subTextLabel.isHidden = true
        
        self.emailInputView.isHidden = true
        self.submitEmailButton.isHidden = true
        self.otherProviderLabel.isHidden = true
            
        self.activityIndicator.startAnimating()
//        self.activityIndicator.isHidden = false
    }
    
    func configureAuthView() {
        if self.authViewController == nil {
            self.authViewController = CustomAuthPickerViewController(authUI: self.authUI)
        } else {
            print("auth already added")
            return
        }
        
        guard let authViewController = self.authViewController,
            let authView = authViewController.view else {
                return
        }
        authView.backgroundColor = .clear
        self.addChild(authViewController)
        self.addSubviewInParent(authView, in: self.containerView, at: 0)
        authViewController.didMove(toParent: self)
    }
    
    func addSubviewInParent(_ subView: UIView, in parent: UIView, at: Int=0) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.frame = parent.bounds
        subView.center = parent.bounds.center
        parent.insertSubview(subView, at: at)
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: parent.topAnchor),
            subView.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            subView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
            ])
        parent.layoutIfNeeded()
    }
    
    func removeAuthViewController() {
        guard let authViewController = self.authViewController else {return}
        
        let authView = authViewController.view
        authViewController.willMove(toParent: nil)
        authView?.removeFromSuperview()
        authViewController.removeFromParent()
        self.authViewController = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension LoginViewController: FUIAuthDelegate, UINavigationControllerDelegate {

    func getTwitterProvider() -> FUIOAuth {
        let twitterImage = CactusImage.twitter.ofWidth(newWidth: 25)
        if #available(iOS 13.0, *) {
            twitterImage?.withTintColor(.white)
        } else {
            // Fallback on earlier versions
        }
//        twitterImage?.resizingMode = .aspectFit
//        twitterImage?.setSize = CGSize(width: 25, height: 25)
        let twitterProvider = FUIOAuth(authUI: self.authUI,
                                                  providerID: "twitter.com",
                                                  buttonLabelText: "Sign in with Twitter",
                                                  shortName: "Twitter",
                                                  buttonColor: CactusColor.twitter,
                                                  iconImage: twitterImage!,
                                                  scopes: ["user.readwrite"],
                                                  customParameters: ["prompt": "consent"],
                                                  loginHintKey: nil)
        return twitterProvider
    }
    
    func configureAuth(_ user: User?=AuthService.sharedInstance.getCurrentUser()) {
        guard let authUI = FUIAuth.defaultAuthUI() else {fatalError("unable to configure auth")}
        authUI.tosurl = URL(string: "https://cactus.app/terms-of-service")
        authUI.privacyPolicyURL = URL(string: "https://cactus.app/privacy-policy")
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = true
        self.authUI = authUI
        
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth(),
            FUIGoogleAuth(),
//            self.getTwitterProvider()
        ]
        
        authUI.providers = providers
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("AUTHDATA RESULT")
        //anonymous auth upgrade
        if let error = error as NSError?,
            error.code == FUIAuthErrorCode.mergeConflict.rawValue {
            print("there was an error logging in... handing different cases" )
            
            // Merge conflict error, discard the anonymous user and login as the existing
            // non-anonymous user.
            guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
                print("Received merge conflict error without auth credential!")
                return
            }
            
            Auth.auth().signIn(with: credential) { (dataResult, error) in
                print("completed signinandretrievedata method")
                if let error = error as NSError? {
                    print("Failed to re-login: \(error)")
                    return
                }
                
                // Handle successful login
                //todo: create user profile?
                let isNewUser = dataResult?.additionalUserInfo?.isNewUser
                if isNewUser ?? false {
                    print("signed up with provider", dataResult?.additionalUserInfo?.providerID ?? "unknown")
                    
                    Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                        AnalyticsParameterMethod: dataResult?.additionalUserInfo?.providerID ?? "unknown",
                        "screen": ScreenID.Login.name,
                        "anonyomousUpgrade": true
                        ])
                } else {
                    print("logged in with provider", dataResult?.additionalUserInfo?.providerID ?? "unknown")
                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
                        AnalyticsParameterMethod: dataResult?.additionalUserInfo?.providerID ?? "unknown",
                        "screen": ScreenID.Login.name,
                        "anonyomousUpgrade": true
                        ])
                }
                
            }
        } else if let error = error {
            // Some non-merge conflict error happened.
            print("Failed to log in: \(error)")
            return
        }
        // end anon user upgrade
        
        // Handle successful login
        print("successful login")
        
        let isNewUser = authDataResult?.additionalUserInfo?.isNewUser
        if isNewUser ?? false {
            print("signed up with provider", authDataResult?.additionalUserInfo?.providerID ?? "unknown")
            
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterMethod: authDataResult?.additionalUserInfo?.providerID ?? "unknown",
                "screen": ScreenID.Login.name
                ])
        } else {
            print("logged in with provider", authDataResult?.additionalUserInfo?.providerID ?? "unknown")
            Analytics.logEvent(AnalyticsEventLogin, parameters: [
                AnalyticsParameterMethod: authDataResult?.additionalUserInfo?.providerID ?? "unknown",
                "screen": ScreenID.Login.name
                ])
        }
    }
}

class CustomAuthPickerViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = view.subviews.first
        scrollView?.backgroundColor = .clear
        
        let pickerView = scrollView?.subviews.first
        pickerView?.backgroundColor = .clear
        
        scrollView?.subviews.forEach({ (view) in
            if let textView = view as? UITextView {
                textView.textAlignment = .center
            }
        })
        
        pickerView?.subviews.forEach({ (view) in
            if let textView = view as? UITextView {
                textView.textAlignment = .center
            }
        })
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField code
        textField.resignFirstResponder()  //if desired
        self.submitMagicLinkEMail(textField.text)
        return true
    }
}
