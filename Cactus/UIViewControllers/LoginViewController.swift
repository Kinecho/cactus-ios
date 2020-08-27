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
import AuthenticationServices

class LoginViewController: UIViewController {
    var authUI: FUIAuth!
    var loggedOutTitle = "Sign In"
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var otherProviderLabel: UILabel!
    @IBOutlet weak var emailInputView: CactusTextInputField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var submitEmailButton: PrimaryButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loadingStackView: UIStackView!
    
    var authViewController: UIViewController?
    
    var authHandler: AuthStateDidChangeListenerHandle?
    var logger = Logger("LoginViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAuth()
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
        self.submitMagicLinkEmail(email)
    }
    
    func showInvalidEmail() {
        let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func submitMagicLinkEmail(_ email: String?) {
        self.submitEmailButton.setEnabled(false)
        self.submitEmailButton.setTitle("Submitting...", for: .disabled)
        guard let email = email?.trimmingCharacters(in: .whitespacesAndNewlines),
            isValidEmail(email) else {
                self.showInvalidEmail()
                self.submitEmailButton.setEnabled(true)
                return
        }
        
        self.logger.info("submitting magic link \(email)")
        UserDefaults.standard.set(email, forKey: UserDefaultsKey.magicLinkEmail)
        let params = StorageService.sharedInstance.getLocalSignupQueryParams()
        var magicLinkRequest = MagicLinkRequest(email: email, continuePath: "/home")
        magicLinkRequest.referredBy = params?["ref"]
        magicLinkRequest.queryParams = params
        ApiService.sharedInstance.sendMagicLink(magicLinkRequest) { (response) in
            DispatchQueue.main.async {
                self.logger.debug("Got magic link response from server")
                self.submitEmailButton.setEnabled(true)
                self.handleMagicLinkResponse(response)
            }            
        }
    }
    
    //TODO: make this show a custom screen
    func handleMagicLinkResponse(_ magicLinkResponse: MagicLinkResponse) {
        let greeting = magicLinkResponse.exists ? "Welcome Back!" : "Welcome!"
        let alert = UIAlertController(title: greeting, message: "Next, \(magicLinkResponse.email) will receive an email from Cactus with a special link. Tap it to sign in.", preferredStyle: .alert)
        if magicLinkResponse.success == false {
            alert.title = "Oops! Something's not right."
            alert.message = magicLinkResponse.error ?? "Something unexpected happened. Please try again later"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func configureUI(_ user: User?=AuthService.sharedInstance.getCurrentUser()) {
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
        self.titleLabel.text = loggedOutTitle
        self.titleLabel.isHidden = false
        self.configureAuthView()
    }
    
    func showLoggedOutUI() {
        self.titleLabel.text = loggedOutTitle
        self.titleLabel.isHidden = false
        self.emailInputView.isHidden = false
        self.submitEmailButton.isHidden = false
        self.otherProviderLabel.isHidden = false
        self.configureAuthView()
        self.cancelButton.isHidden = true
        self.loadingStackView.isHidden = false
    }
    
    func showLoggedInUI(_ user: User) {
        self.removeAuthViewController()
        self.titleLabel.isHidden = true
        
        self.emailInputView.isHidden = true
        self.submitEmailButton.isHidden = true
        self.otherProviderLabel.isHidden = true
        
        self.activityIndicator.startAnimating()
        self.loadingStackView.isHidden = false
        self.cancelButton.isHidden = false
        //        self.activityIndicator.isHidden = false
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        AuthService.sharedInstance.logout()
    }
    
    func configureAuthView() {
        if self.authViewController == nil {
            self.authViewController = CustomAuthPickerViewController(authUI: self.authUI)
        } else {
            self.logger.debug("auth already added")
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
    
    func configureAuth() {
        guard let authUI = FUIAuth.defaultAuthUI() else {fatalError("unable to configure auth")}
        authUI.tosurl = URL(string: "https://cactus.app/terms-of-service")
        authUI.privacyPolicyURL = URL(string: "https://cactus.app/privacy-policy")
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = true
        self.authUI = authUI
//        FUIApple
//        FUIOAuth.twitter
        var providers: [FUIAuthProvider] = [
            FUIFacebookAuth(),
            FUIGoogleAuth(),
        ]
        if #available(iOS 13.0, *) {
            providers.insert(FUIOAuth.appleAuthProvider(), at: 0)
        }
        
        authUI.providers = providers
    }
    
    func handleAnonymousUpgrade(error: NSError) {
        logger.info("handling anonymous user upgrade flow")
        
        // Merge conflict error, discard the anonymous user and login as the existing
        // non-anonymous user.
        guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
            self.logger.error("Received merge conflict error without auth credential!", error)
            return
        }
        
        Auth.auth().signIn(with: credential) { (dataResult, error) in
            self.logger.info("completed signinandretrievedata method")
            if let error = error as NSError? {
                self.logger.error("Failed to re-login: \(error)")
                return
            }
            
            if let authData = dataResult {
                UserService.sharedInstance.handleSuccessfulLogIn(authData, screen: ScreenID.Login, anonymousUpgrade: true)
            } else {
                self.logger.warn("No auth data was found in the signin handler", functionName: #function, line: #line)
            }
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        self.logger.info("Auth did sign in finished... handling result now.", functionName: #function)
        //anonymous auth upgrade
        if let error = error as NSError? {
            let code = UInt(error.code)
            switch code {
            case FUIAuthErrorCode.mergeConflict.rawValue:
                self.handleAnonymousUpgrade(error: error)
            default:
                self.logger.error("There was an unhandled error while logging.", error, functionName: #function)
            }
        } else if let authResult = authDataResult {
            self.logger.info("successful login")
            UserService.sharedInstance.handleSuccessfulLogIn(authResult)
        } else {
            self.logger.warn("No auth result was found, but there was no error. This should never occur", functionName: #function, line: #line)
        }
    }
}

class CustomAuthPickerViewController: FUIAuthPickerViewController {
    var hasAdjustedFrame = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let scrollView = view.subviews.first
        scrollView?.backgroundColor = .clear
        
        let contentContainerView = scrollView?.subviews.first
        contentContainerView?.backgroundColor = .clear
        
        scrollView?.subviews.forEach({ (view) in
            if let textView = view as? UITextView {
                textView.textAlignment = .center
            }
        })
        
        contentContainerView?.subviews.forEach({ (view) in
            if let textView = view as? UITextView {
                textView.textAlignment = .center
                textView.textColor = CactusColor.white
                textView.tintColor = CactusColor.white
                textView.linkTextAttributes = [
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.underlineColor: CactusColor.white,
                    NSAttributedString.Key.foregroundColor: CactusColor.white,
                ]
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        
        let scrollView = view.subviews.first
        scrollView?.backgroundColor = .clear
    
        let contentContainerView = scrollView?.subviews.first
        let buttonWrapperView = contentContainerView?.subviews.first
        
        if !hasAdjustedFrame {
            super.viewDidLayoutSubviews()
            if let containerOriginalFrame = contentContainerView?.frame {
                contentContainerView!.frame = CGRect(x: containerOriginalFrame.minX, y: 0, width: containerOriginalFrame.width, height: containerOriginalFrame.height - containerOriginalFrame.minY)
            }
                        
            if let buttonWrapperOriginalFrame = buttonWrapperView?.frame {
                buttonWrapperView?.frame = CGRect(x: buttonWrapperOriginalFrame.minX,
                                                  y: 0,
                                                  width: buttonWrapperOriginalFrame.width,
                                                  height: buttonWrapperOriginalFrame.height - buttonWrapperOriginalFrame.minY)
            }
        }

        buttonWrapperView?.subviews.forEach { (subview) in
            if let button = subview as? UIButton {
                button.layer.cornerRadius = 6
            }
        }
        self.hasAdjustedFrame = true
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField code
        textField.resignFirstResponder()  //if desired
        self.submitMagicLinkEmail(textField.text)
        return true
    }
}
