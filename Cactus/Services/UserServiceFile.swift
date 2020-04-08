//
//  File.swift
//  Cactus
//
//  Created by Neil Poulin on 11/15/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseUI

class UserService {
    static let sharedInstance = UserService()
    var logger = Logger("UserService")
    
    var loginMemberListener: Unsubscriber?
    
    func handleActivityURL(_ activityUrl: URL) -> Bool {
        var params = activityUrl.getQueryParams()
        var signinUrl: URL?
        let path = activityUrl.path
        if let linkParam = params["link"] {
            signinUrl = URL(string: linkParam)
            params = signinUrl?.getQueryParams() ?? params
        }
        logger.info("Setting local signup query params to \(String(describing: params) )")
        StorageService.sharedInstance.setLocalSignupQueryParams(params)
        
        if Auth.auth().isSignIn(withEmailLink: activityUrl.absoluteString) {
            logger.info("Signing in user with magic link")
            let email = UserDefaults.standard.string(forKey: UserDefaultsKey.magicLinkEmail)
            if let email = email {
                self.signinWithEmail(email, link: activityUrl.absoluteString)
            } else {
                self.confirmEmailAddress(link: activityUrl.absoluteString)
            }
            return true
        } else if let signinUrl = signinUrl {
            if FUIAuth.defaultAuthUI()?.handleOpen(signinUrl, sourceApplication: nil) ?? false {
                self.logger.info("Handled by firebase auth ui")
                return true
            }
        } else if path == "/signup" || path == "/login" {
            return true
        }
        
        return false
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        AppMainViewController.shared.present(alert, animated: true)
    }
    
    func signinWithEmail(_ email: String, link: String) {
        if !isValidEmail(email) {
            self.confirmEmailAddress(link: link, message: "Please enter a valid email address")
            return
        }
        
        Auth.auth().signIn(withEmail: email, link: link) { (authResult, error) in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    self.logger.error("Auth sign in with email errorCode \(errorCode)", functionName: #function, line: #line)
                    switch errorCode {
                    case .invalidEmail:
                        return self.confirmEmailAddress(link: link, message: "\(email) does not match the email address the sign in link was sent to. Please try again.")
                    case .invalidActionCode:
                        self.logger.warn("The signin link was invalid - may have expired or was already used")
                        self.showErrorAlert(title: "Unable to sign in", message: "This link may have been use already, is expired, or malformed. Please try again.")
                    default:
                        self.logger.error("Error logging in", error.localizedDescription)
                        self.showErrorAlert(title: "Oops! Unable to sign in", message: error.localizedDescription)
                    }
                }
            } else if let authResult = authResult {
                self.handleSuccessfulLogIn(authResult)
                self.logger.info("Successfully logged in. AuthResult, \(authResult.user.email ?? "no email found")" )
            }
        }
    }
    
    func handleSuccessfulLogIn(_ authResult: AuthDataResult, screen: ScreenID?=nil, anonymousUpgrade: Bool=false) {
        DispatchQueue.global(qos: .background).async {
            var loginEvent = LoginEvent()
            loginEvent.isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            loginEvent.providerId = authResult.additionalUserInfo?.providerID
            loginEvent.userId = authResult.user.uid
            loginEvent.signupQueryParams = StorageService.sharedInstance.getLocalSignupQueryParams()
            loginEvent.referredByEmail = StorageService.sharedInstance.getLocalSignupQueryParams()?["ref"]
            loginEvent.email = authResult.user.email
            
            self.logger.info("User login success. Referred By Email \(loginEvent.referredByEmail ?? "none")")
            
            CactusAnalytics.shared.sendLoginAnalyticsEvent(loginEvent, screen: screen, anonymousUpgrade: anonymousUpgrade)
            
            self.loginMemberListener = CactusMemberService.sharedInstance.observeCurrentMember { (member, _, _) in
                if member != nil {
                    self.logger.info("Cactus member was found, sending login event")
                    ApiService.sharedInstance.sendLoginEvent(loginEvent, completed: { error in
                        if let error = error {
                            self.logger.error("Failed to send login event", error)
                            return
                        }
                        self.logger.info("login event completed")
                    })
                    
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKey.magicLinkEmail)
                    StorageService.sharedInstance.removeLocalSignupQueryParams()
                    self.loginMemberListener?()
                } else {
                    self.logger.info("No cactus member found.. still waiting")
                }
            }
        }
    }
    
    func confirmEmailAddress(link: String, message: String = "Please enter your email address") {
        let emailAlert = UIAlertController(title: "Confirm your Email", message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            if let inputEmail = emailAlert.textFields?.first?.text {
                self.signinWithEmail(inputEmail, link: link)
            }
        })
        submitAction.isEnabled = false
        
        emailAlert.addTextField { (textField) in
            textField.placeholder = "Enter your email"
            textField.layer.borderColor = CactusColor.green.cgColor
            textField.frame = CGRect(textField.frame.minX, textField.frame.minY, textField.frame.width, 40)
            textField.layer.cornerRadius = 20
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
            textField.returnKeyType = .done
            textField.layoutIfNeeded()
            textField.addTarget(emailAlert, action: #selector(emailAlert.textDidChangeInEmailConfirmAlert), for: .editingChanged)
        }
        
        emailAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        emailAlert.addAction(submitAction)
        
        AppMainViewController.shared.present(emailAlert, animated: true)
    }
    
    func deleteUserPermenantly(completion: @escaping (DeleteUserResult) -> Void) {
        guard let member = CactusMemberService.sharedInstance.currentMember else {
            completion(DeleteUserResult(success: false))
            return
        }
        let params = DeleteUserParams(email: member.email)
        ApiService.sharedInstance.post(path: ApiPath.deleteUser, body: params, responseType: DeleteUserResult.self, authenticated: true) { result, error in
            if let error = error {
                self.logger.error("Unable to delete the user. no suuccess returned or there was an error", error)
                completion(DeleteUserResult(success: false))
                return
            }
            
            if let result = result {                
                completion(result)
                return
            }
            completion(DeleteUserResult(success: false))
            return
        }
    }
}
