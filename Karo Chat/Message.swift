//
//  Message.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 23/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    //var time : String?
    var fromId : String?
    var text : String?
    var timeStamp : NSNumber?
    var toId : String?
    
    var imageUrl: String?
    
    var imageHeight : NSNumber?
    var imageWidth : NSNumber?
    
    func chatPartenerId() -> String? {
        
        //checking users fromId and toId
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
//    init(dictionary : [String : AnyObject]) {
//        super.init()
//        fromId = dictionary["fromId"] as? String
//        text = dictionary["text"] as? String
//        timeStamp = dictionary["timeStamp"] as? NSNumber
//        toId = dictionary["toId"] as? String
//        
//        imageUrl = dictionary["imageUrl"] as? String
//        imageHeight = dictionary["imageHeight"] as? NSNumber
//        imageWidth = dictionary["imageWidth"] as? NSNumber
//    }
}
