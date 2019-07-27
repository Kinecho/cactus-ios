//
//  UserService.swift
//  Cactus
//
//  Created by Neil Poulin on 7/25/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import FirebaseAuth
class AuthService {
    
    static let sharedInstance = AuthService()
    let firestore:FirestoreService;
    
    private init(){
        self.firestore = FirestoreService.sharedInstance;
    }
    
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
        
    }
    
    func logOut(_ vc: UIViewController) {
        
        var  message = "Are you sure you want to log out?"
        if let user = getCurrentUser(), (user.displayName != nil || user.email != nil) {
            var name = user.email
            if name == nil {
                name = user.displayName
            }
            if name != nil {
                message = "Are you sure you want to log out of \(name!)?"
            }
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive){ _ in
            CactusMemberService.sharedInstance.removeFCMToken(onCompleted: { (error) in
                if error != nil {
                    print("Failed to remove tokens from Cactus User. Oh well - still logging out", error!)
                }
                do{
                    try Auth.auth().signOut()
                    vc.dismiss(animated: false, completion: nil)
                } catch {
                    print("error signing out", error)
                    let alert = UIAlertController(title: "Error Logging Out", message: "An unexpected error occurred while logging out. \n\n\(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    vc.present(alert, animated: true)
                }
            })
        })
        
        vc.present(alert, animated: true)
        
    }
    
    func getAuthStateChangeHandler(completion: @escaping (Auth, User?) -> Void) -> AuthStateDidChangeListenerHandle {
        let handle = Auth.auth().addStateDidChangeListener(completion)
        return handle
    }
    
    func removeAuthStateChangeListener(_ listener: AuthStateDidChangeListenerHandle?){
        if listener != nil {
            Auth.auth().removeStateDidChangeListener(listener!)
        }
    }
    
}
