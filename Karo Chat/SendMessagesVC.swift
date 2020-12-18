//
//  CollectionViewController.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 29/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

private let reuseIdentifier = "Cell"

class SendMessagesVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let inputTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 15
        textField.placeholder = "Leave your message here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var messages = [Message]()
    
    var user : FetchUsers? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        //fetching all the messages for current user logged in
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
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
                let message = Message()//Message(dictionary: dictionary)
                //potential of crashing if key don't match
                message.setValuesForKeys(dictionary)
                //print(message.text ?? "")
                
                self.messages.append(message)
                self.collectionView?.reloadData()
                
                //Scroll to the last message(index)
                let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                
            }, withCancel: nil)
        }, withCancel: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collection1.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        collectionView?.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! SendMessagesCollectionCell
    
        let message = messages[indexPath.item]
        cell.messageTextContainerCell.text = message.text
        
        //setting different color and position for cell on the basis of toId and fromId
        self.setUpCell(cell: cell, message: message)
        
        //modifying bubble View width as per message width
        if let text = message.text {
            cell.bubbleViewWidthConstraint?.constant = estimateFrameHeightForText(text: text).width + 20
            cell.messageTextContainerCell.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            cell.messageTextContainerCell.isHidden = true
        }
        
        //for making image zoomable
        cell.messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        cell.messageImageView.isUserInteractionEnabled = true
        
        return cell
    }
    
    //setting up cell
    private func setUpCell(cell : SendMessagesCollectionCell, message : Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        //settin imageView inside the bubble
        if let imageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
            cell.messageImageView.isHidden = false
        } else {
            cell.messageImageView.isHidden = true
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
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //calculating height of the message depending on the string length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let width = UIScreen.main.bounds.width
        //get estimated height for message
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameHeightForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: width, height: height)
    }
    
    
    private func estimateFrameHeightForText(text : String) -> CGRect {
        
        let size = CGSize(width: 200/*self.view.frame.width / 2*/, height: 5000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func handleZoomTap(tapGesture : UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            self.performZoominForImage(startingImageView: imageView)
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoominForImage(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame!)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image    //giving image to zoom
        
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                //h2 / w1 = h1 / w1   :-    h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    func handleSend() {
        
        if inputTextField.text == "" {
            
            inputTextField.attributedPlaceholder = NSAttributedString(string: "Can't send empty msg", attributes: [NSForegroundColorAttributeName: UIColor.red])
        } else {
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
                let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId : 1])
                
                let recepientUserMessageRefernce = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recepientUserMessageRefernce.updateChildValues([messageId : 1])
            }
            inputTextField.text = ""
            inputTextField.placeholder = "Leave your message here..."
        }
    }
    
    func handleShare() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        //to send the image
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image : UIImage) {
         let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to send the image : " , error ?? "")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl : String, image : UIImage) {
            let ref = Database.database().reference().child("Chats")
            let childRef = ref.childByAutoId()
            let toId = user!.id!
            let fromId = Auth.auth().currentUser!.uid
            let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
            let values = ["toId" : toId, "fromId" : fromId, "timeStamp" : String(timeStamp), "imageUrl" : imageUrl, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : Any]
            childRef.updateChildValues(values) { (err, ref) in
                
                if err != nil {
                    print(err ?? "")
                    return
                }
                let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
                let messageId = childRef.key
                userMessageRef.updateChildValues([messageId : 1])
                
                let recepientUserMessageRefernce = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recepientUserMessageRefernce.updateChildValues([messageId : 1])
            }
    }
    
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
    
    
    
    func handleKeyBoardDidShow() {
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
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
