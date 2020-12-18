//
//  RegisteredUsersVC.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 11/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class MyChatsVC: UITableViewController {
    
    var messages = [Message]()  //holding all the chats
    var messageDictionary = [String: Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // checking if user is logged in or not
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logoutHandling), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetNameOnTitleBar()
        }
        tableView.tableFooterView = UIView()
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                //print(snapshot)
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId : String) {
        let messageReference = Database.database().reference().child("Chats").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message()//Message(dictionary: dictionary)
                 message.setValuesForKeys(dictionary)
                //self.messages.append(message)
                
                //code to group messages within a single chat
                if let chatPartnerId = message.chatPartenerId() {
                    self.messageDictionary[chatPartnerId] = message
                    
                }
                
                self.attempReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    var timer : Timer?
    
    func attempReloadOfTable() {
        //tableView reloading many time as number of chats appears in the list to fix the issue I'm using NSTimer here
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleTableViewReload), userInfo: nil, repeats: false)
    }
    
    func handleTableViewReload() {
        
        self.messages = Array(self.messageDictionary.values)
        
        //sorting chat with date and time
        self.messages.sort(by: { (messageTime1, messageTime2) -> Bool in
            return (messageTime1.timeStamp?.intValue)! > (messageTime2.timeStamp?.intValue)!
        })
        
        //this will crash because of background thread
        //dispatchMain()
        self.tableView.reloadData()
    }
    
    func fetchUserAndSetNameOnTitleBar()    //fixing bug for login and registration name
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("KaroChatAppUsers").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String : AnyObject]
            {
                self.title = dictionary["name"] as? String
                
                //removing all the chats while logging in for faster access of messages
                self.messages.removeAll()
                self.messageDictionary.removeAll()
                self.tableView.reloadData()
                
                //calling all the chats from firebase database
                self.observeUserMessages()
                
//                //for profile menu
//                let user = FetchUsers()
//                user.setValuesForKeys(dictionary)
//                self.setUpProfile(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setUpProfile(user : FetchUsers)
    {
        self.title = user.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyChatsTableCell
        
        let message = messages[indexPath.row]
        
        //fetching chatPartnerId from Message Class
        
        if let id = message.chatPartenerId() {
            let ref = Database.database().reference().child("KaroChatAppUsers").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    cell.userName.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["ProfileImageUrl"] as? String {
                        cell.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
                //print(snapshot)
            }, withCancel: nil)
        }
        cell.userText.text = message.text
        
        if let seconds = message.timeStamp?.doubleValue {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.messageTime.text = dateFormatter.string(from: timeStampDate as Date)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartenerId() else {
            return
        }
        
        let ref = Database.database().reference().child("KaroChatAppUsers").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = FetchUsers()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            
            //redirecting to SendMessageVC
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "SB-SendMessage") as! SendMessagesVC
            VC.user = user
            self.navigationController?.pushViewController(VC, animated: true)//present(VC, animated: true, completion: nil)
            
        }, withCancel: nil)
    }

    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.tableView.reloadData()
        } catch let error {
            print("An error occured while logging out", error)
        }
        
        let VCToDisplay = self.storyboard?.instantiateViewController(withIdentifier: "SB-LoginRegister") as! LoginSignUpVC
        let VC = LoginSignUpVC()
        VC.nameForTitleBar = self
        //self.view.reloadInputViews()
        present(VCToDisplay, animated: true, completion: nil)
    }
    
    func logoutHandling()
    {
        do {
            try Auth.auth().signOut()
            self.tableView.reloadData()
        } catch let error {
            print("An error occured while logging out", error)
        }
        
        let VCToDisolay = self.storyboard?.instantiateViewController(withIdentifier: "SB-LoginRegister") as! LoginSignUpVC
        let VC = LoginSignUpVC()
        VC.nameForTitleBar = self
        present(VCToDisolay, animated: true, completion: nil)
    }
}
