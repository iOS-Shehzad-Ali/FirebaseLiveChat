//
//  MyProfileVC.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 22/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class MyProfileVC: UIViewController {
    
    @IBOutlet weak var userPic: DesignableImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchUserAndSetNameAndImage()
        //self.userPic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showMessageController)))
        //userPic.isUserInteractionEnabled = true
    }
    
    func fetchUserAndSetNameAndImage()
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("KaroChatAppUsers").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String : AnyObject]
            {
                self.title = dictionary["name"] as? String
                if let profileUrl = dictionary["ProfileImageUrl"]
                {
                    self.userPic.loadImageUsingCacheWithUrlString(urlString: profileUrl as! String)
                }
/*
                //for profile menu
                 let user = FetchUsers()
                 user.setValuesForKeys(dictionary)
                 self.setUpProfile(user: user)
*/
            }
            
            
        }, withCancel: nil)
        
    }
    
    func setUpProfile(user : FetchUsers)
    {
        print(user.name ?? "")
    }
    
    func showMessageController()
    {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SB-SendMessage")
        self.navigationController?.pushViewController(VC!, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
