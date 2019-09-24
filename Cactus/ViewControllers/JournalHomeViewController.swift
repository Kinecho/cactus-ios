//
//  JournalHomeViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/23/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import Firebase

class JournalHomeViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    
    var memberListener:(() -> Void)?
    
    var member: CactusMember? {
        didSet {
            self.updateViewForMember(member: self.member)
        }
    }
    
    var user: Firebase.User? {
        didSet {
            self.updateViewForUser(user: self.user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(tapGestureRecognizer:)))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapGestureRecognizer)
        
        self.memberListener = CactusMemberService.sharedInstance.observeCurrentMember { (member, error, user) in
            if let error = error {
                print("error observing cactus member", error)
            }
            self.user = user
            self.member = member
        // Do any additional setup after load
        }
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        self.memberListener?()
    }

    func setupView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
    }
    
    func updateViewForMember(member: CactusMember?) {
        
    }
    
    func updateViewForUser(user: Firebase.User?) {
        
        if let imageUrl = user?.photoURL {
            ImageService.shared.setFromUrl(self.profileImageView, url: imageUrl)
        } else {
            self.profileImageView.image = CactusImage.cactusAvatarOG.getImage()
        }
        
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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
