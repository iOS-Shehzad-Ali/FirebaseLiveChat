//
//  RegisteredUsersVCR.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 12/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class RegisteredUsersVC: UITableViewController {

    var users = [FetchUsers]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsersFromFirebaseDatabase()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisteredUsersCell", for: indexPath) as! RegisteredUsersTableCell

        cell.userNameLabel.text = users[indexPath.row].name
        cell.userEmailLabel.text = users[indexPath.row].email
        //cell.profileImageView.image = UIImage(named: "default_profile")
        //cell.imageView?.contentMode = .scaleAspectFill
        
        if let imageUrl = users[indexPath.row].profileImageUrl
        {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
/*            let url = URL(string: imageUrl)
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil
                {
                    print("Error in downloading image from Firebase database", error ?? "")
                    return
                }
                cell.profileImageView.image = UIImage(data: data!)
            }).resume()
*/
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let user = self.users[indexPath.row]
            self.showChatControllerForUser(user: user)
        
    }
    
    func showChatControllerForUser(user : FetchUsers?)
    {
        
//        let VC = SendMessagesVC()
//        VC.user = user
//        present(VC, animated: true, completion: nil)

        let VC = self.storyboard?.instantiateViewController(withIdentifier: "SB-SendMessage") as! SendMessagesVC
        VC.user = user
        self.navigationController?.pushViewController(VC, animated: true)//present(VC, animated: true, completion: nil)

    }

    @IBAction func backButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUsersFromFirebaseDatabase()
    {
        Database.database().reference().child("KaroChatAppUsers").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject]
            {
                let newUser = FetchUsers()  //creating new user
                newUser.id = snapshot.key   //for message key while chatting
                newUser.setValuesForKeys(dictionary)
                self.users.append(newUser)
                //this will crash because of background threads that is why I am using here dispatch_async method to fix
                //dispatchMain()
                self.tableView.reloadData()
                
                
                //print(newUser.name, newUser.email)
            }
            
        }, withCancel: nil)
    }
}
