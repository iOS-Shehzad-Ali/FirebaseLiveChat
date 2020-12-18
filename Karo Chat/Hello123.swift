//
//  SendMessagesVC.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 23/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class Hello123: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let inputTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 15
        textField.placeholder = "Leave your message here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    //var containerViewBottomAncor : NSLayoutAnchor?
    
    @IBOutlet weak var collection1: UICollectionView!
    
    @IBOutlet weak var collection1BottomAnchor: NSLayoutConstraint!
    
    
    var messages = [Message]()
    
    var user : FetchUsers? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        //fetching all the messages for current user logged in
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            //print(snapshot)
            
            //fetching all the messages on the basis of unique id for each message
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("Chats").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
                
                //binding all the messages in an array
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()//Message(dictionary : dictionary)
                //print(message.text ?? "")
                message.setValuesForKeys(dictionary)
                
                //filtering all the messages as per user chats
                if message.chatPartenerId() == self.user?.id {
                    self.messages.append(message)
                    self.collection1.reloadData()
                }
                
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection1.dataSource = self
        collection1.delegate = self
        collection1.alwaysBounceVertical = true
        collection1.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collection1.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        collection1.keyboardDismissMode = .interactive
        inputTextField.delegate = self
        
/*
        //handling keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
*/
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection1.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! SendMessagesCollectionCell
        let message = messages[indexPath.item]
        cell.messageTextContainerCell.text = message.text
        
        //setting different color and position for cell on the basis of toId and fromId
        self.setUpCell(cell: cell, message: message)
        
        //modifying bubble View width as per message width
        cell.bubbleViewWidthConstraint?.constant = estimateFrameHeightForText(text: message.text!).width + 20
        
        return cell
    }
    
    //setting up cell
    private func setUpCell(cell : SendMessagesCollectionCell, message : Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            
            //for outgoing messages
            
            cell.bubbleView.backgroundColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
            cell.messageTextContainerCell.textColor = UIColor.white
            cell.profileImage.isHidden = true
            cell.bubbleViewRightConstraint?.isActive = true
            cell.bubbleView.leftAnchor.constraint(equalTo: cell.profileImage.rightAnchor, constant: 5).isActive = false
        } else {
            
            //for incoming messages
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.messageTextContainerCell.textColor = UIColor.black
            cell.profileImage.isHidden = false
            
            cell.bubbleView.leftAnchor.constraint(equalTo: cell.profileImage.rightAnchor, constant: 5).isActive = true
            cell.bubbleViewRightConstraint?.isActive = false
        }
    }
    
    //adding this method for autolayout(rotating the simulator)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collection1.collectionViewLayout.invalidateLayout()
    }
    
    //calculating height of the message depending on the string length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height for message
        if let text = messages[indexPath.item].text {
            height = estimateFrameHeightForText(text: text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    private func estimateFrameHeightForText(text : String) -> CGRect {
        
        let size = CGSize(width: 200/*self.view.frame.width / 2*/, height: 5000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func handleSend() {
        let ref = Database.database().reference().child("Chats")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
        //let date = self.getCurrentDate()
        //let time = self.getCurrentTime()
        let values = ["text" : inputTextField.text!, "toId" : toId, "fromId" : fromId, "timeStamp" : String(timeStamp)]//"date" : date, "time" : time]
        //childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (err, ref) in
            
            if err != nil {
                print(err ?? "")
                return
            }
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId : 1])
            
            let recepientUserMessageRefernce = Database.database().reference().child("user-messages").child(toId)
            recepientUserMessageRefernce.updateChildValues([messageId : 1])
        }
        inputTextField.text = ""
    }
    
    func handleShare() {
        print(123)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        collection1BottomAnchor.constant = 290
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        collection1BottomAnchor.constant = 40
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
//    func handleKeyboardWillShow(notification : NSNotification) {
//        
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        //inputContainerView.frame = (keyboardFrame!.height)
//        
//    }
    
    //for dismissal of keyboard
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
        containerView.backgroundColor = UIColor.lightGray
        
        let shareButton = UIButton()
        shareButton.setImage(UIImage(named: "send-2"), for: .normal)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        containerView.addSubview(shareButton)
        //constraint for share button like x,y,width,height
        shareButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        shareButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        shareButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let sendButton = UIButton()
        sendButton.setImage(UIImage(named: "send-3"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //constraint for send button like x,y,width,height
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        //constraint for textFeild like x,y,width,height
        self.inputTextField.leftAnchor.constraint(equalTo: shareButton.rightAnchor, constant: 5).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -5).isActive = true
        self.inputTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.black//UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        //constraint for seperatorLineView like x,y,width,height
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: 5).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
 
//    func keyboardUp(notification : NSNotification)
//    {
//        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        //inputContainerView.frame = (keyboardFrame!.height)
//        
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        UIView.animate(withDuration: keyboardDuration!) { 
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    func keyboardDown(notification : NSNotification) {
//        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
//        
//        //inputContainerView.frame = 0
//        UIView.animate(withDuration: keyboardDuration!) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return "\(formatter.string(from: date))"
    }
    
    func getCurrentTime() -> String {
/*
        let date = Date()
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let minute = calender.component(.minute, from: date)
        return "\(hour):\(minute)"
*/
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timeString = formatter.string(from: date)
        return "\(timeString)"
        
    }
}
