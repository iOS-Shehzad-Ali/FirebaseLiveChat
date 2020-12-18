//
//  CollectionViewCell.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 29/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

class SendMessagesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: DesignableImageView!
    
    @IBOutlet weak var bubbleView: DesignableView!
    
    @IBOutlet weak var messageTextContainerCell: UITextView!
    
    @IBOutlet weak var bubbleViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageImageView: UIImageView!
    
}
