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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var authViewController: UIViewController?
    
    var authHandler: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.authHandler = AuthService.sharedInstance.getAuthStateChangeHandler { (_, user) in
            self.configureUI(user)
        }
    }
    
    deinit {
        AuthService.sharedInstance.removeAuthStateChangeListener(self.authHandler)
    }
    
    func configureUI(_ user: User?=AuthService.sharedInstance.getCurrentUser()) {
        self.configureAuth(user)
        if let user = user {
            if !user.isAnonymous {
                showLoggedInUI(user)
            } else {
                showAnonymousUserUI(user)
                self.signOutButton.isHidden = false
            }
        } else {
            
            showLoggedOutUI()
        }
    }
    
    func showAnonymousUserUI(_ user: User) {
        self.titleLabel.text = anonymousUserTitle
        self.subTextLabel.text = anonymousSubtitle
        self.signOutButton.isHidden = true
        self.titleLabel.isHidden = false
        self.subTextLabel.isHidden = false
        self.configureAuthView()
    }
    
    func showLoggedOutUI() {
        self.titleLabel.text = loggedOutTitle
        self.subTextLabel.text = loggedOutSubtitle
        self.signOutButton.isHidden = true
        self.titleLabel.isHidden = false
        self.subTextLabel.isHidden = false
        self.configureAuthView()
    }
    
    func showLoggedInUI(_ user: User) {
        self.removeAuthViewController()
        self.titleLabel.text = user.email
        self.subTextLabel.isHidden = true
        self.signOutButton.isHidden = false
    }
    
    func configureAuthView() {
        if self.authViewController == nil {
            self.authViewController = CustomAuthPickerViewController(authUI: self.authUI)
        } else {
            print("auth already added")
            return
        }
        
        guard let authViewController = self.authViewController,
            let authView = authViewController.view else {return}
        
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
    
    @IBAction func signOut(_ sender: Any) {
        print("attempting ot sign out")
//        let user = AuthService.sharedInstance.getCurrentUser()
        
        let title = "Are you sure yoyu wan to sign out?"
    
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try self.authUI.signOut()
                self.dismiss(animated: false, completion: nil)
            } catch {
                print("error signing out", error)
                let alert = UIAlertController(title: "Error Logging Out", message: "An unexpected error occurred while logging out. \n\n\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        })
        
        self.present(alert, animated: true)
        
    }
}

extension LoginViewController: FUIAuthDelegate, UINavigationControllerDelegate {
    
    func configureAuth(_ user: User?=AuthService.sharedInstance.getCurrentUser()) {
        guard let authUI = FUIAuth.defaultAuthUI() else {fatalError("unable to configure auth")}
        
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = true
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://cactus-app-stage.web.app")    
        actionCodeSettings.handleCodeInApp = true
        
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(authAuthUI: authUI, signInMethod: EmailLinkAuthSignInMethod, forceSameDevice: false, allowNewEmailAccounts: true, actionCodeSetting: actionCodeSettings),
            FUIFacebookAuth(),
            FUIGoogleAuth(),
            FUITwitterAuth()
//            FUIPhoneAuth(authUI:authUI),
        ]
        
        authUI.providers = providers
        
        self.authUI = authUI
    }
    
    // Customize the default auth picker view controller
    //    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
    //        return CustomAuthPickerViewController(authUI: authUI)
    //    }
    
    //    func emailEntryViewController(forAuthUI authUI: FUIAuth) -> FUIEmailEntryViewController {
    //        return CustomEmailEntryViewController(authUI: authUI)
    //    }
    
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
            
            Auth.auth().signInAndRetrieveData(with: credential) { (dataResult, error) in
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
        
//        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.navigationBar.isHidden = false
//        self.title = "Hello!!"
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
