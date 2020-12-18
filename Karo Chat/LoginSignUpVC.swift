//
//  ViewController.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 10/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class LoginSignUpVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var nameForTitleBar : MyChatsVC?   //fixing bug for login and registration name
    
    @IBOutlet weak var registratiionView: UIView!
    @IBOutlet weak var nameRegisterTxt: UITextField!
    @IBOutlet weak var emailRegisterTxt: UITextField!
    @IBOutlet weak var passwordRegisterTxt: UITextField!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailLoginTxt: UITextField!
    @IBOutlet weak var passwordLoginTxt: UITextField!
    
    @IBOutlet weak var segmentObject: UISegmentedControl!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameRegisterTxt.delegate = self
        emailRegisterTxt.delegate = self
        passwordRegisterTxt.delegate = self
        emailLoginTxt.delegate = self
        passwordLoginTxt.delegate = self
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickProfilePicture)))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        registratiionView.isHidden = true
        loginView.isHidden = false
    }
    
    @IBAction func segmentAtIndexPressed(_ sender: Any)
    {
        switch segmentObject.selectedSegmentIndex {
        case 0:
            loginView.isHidden = false
            registratiionView.isHidden = true
        case 1:
            registratiionView.isHidden = false
            loginView.isHidden = true
        default:
            return
        }
    }
    
    @IBAction func registrationPressed(_ sender: Any)
    {
        
        guard let name = nameRegisterTxt.text, let email = emailRegisterTxt.text, let password = passwordRegisterTxt.text else {
            print("The form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user : User?, error) in
            if error != nil
            {
                print("An error occured while creating user", error ?? "")
                return
            }
            //when user successfully created
            print("User created successfully")
            guard let uid = user?.uid else {return}
            
            //uploading image to FIRStorage
            let imageName = NSUUID().uuidString
            let storageReference = Storage.storage().reference().child("KaroChatAppUsersProfilePic").child("\(imageName).jpg")   //it may be .png as well
            
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
            {
            
            //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!)
            //{
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil
                    {
                        print("The error in uploading profile pic is : ", error?.localizedDescription ?? "")
                        return
                    }
                    print(metadata ?? "")
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    {
                        let userDetails = ["name" : name, "email" : email, "ProfileImageUrl" : profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, userDetails: userDetails as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid : String, userDetails : [String : AnyObject])
    {
        let ref = Database.database().reference()
        let usersReference = ref.child("KaroChatAppUsers").child(uid)
        
        usersReference.updateChildValues(userDetails, withCompletionBlock: { (err, ref) in
            if err != nil
            {
                print("Error in creating a user", err ?? "")
                return
            }
            print("User successfully created in firebase database")
            
            self.navigationController?.navigationItem.title = userDetails["name"] as? String
            //self.nameForTitleBar?.fetchUserAndSetNameOnTitleBar() //fixing bug for login and registration name
/*
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "SB-MyChats") as! MyChatsVC
            VC.fetchUserAndSetNameOnTitleBar()
*/
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any)
    {
        
        guard let email = emailLoginTxt.text, let password = passwordLoginTxt.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil
            {
                print("An error occured while logging into account", error ?? "")
            }
            print("User successfully logged into account", user ?? "")
            self.nameForTitleBar?.fetchUserAndSetNameOnTitleBar()   //fixing bug for login and registration name
/*
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "SB-MyChats") as! MyChatsVC
            VC.fetchUserAndSetNameOnTitleBar()
*/
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameRegisterTxt.resignFirstResponder()
        emailRegisterTxt.resignFirstResponder()
        passwordRegisterTxt.resignFirstResponder()
        emailLoginTxt.resignFirstResponder()
        passwordLoginTxt.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameRegisterTxt.resignFirstResponder()
        emailRegisterTxt.resignFirstResponder()
        passwordRegisterTxt.resignFirstResponder()
        emailLoginTxt.resignFirstResponder()
        passwordLoginTxt.resignFirstResponder()
        return true
    }
    
    func pickProfilePicture()
    {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = true
        
        present(image, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
             self.profileImageView.image = image
        }
        else
        {
            print("There is error while picking profile image")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled tapped")
        dismiss(animated: true, completion: nil)
        
    }
    
    
}

