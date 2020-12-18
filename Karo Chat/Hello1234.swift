//
//  ChatsCollectionViewCell.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 27/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

class Hello1234: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: DesignableImageView!
    @IBOutlet weak var bubbleView: DesignableView!
    @IBOutlet weak var messageTextContainerCell: UITextView!
    @IBOutlet weak var bubbleViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var bubbleViewRightConstraint: NSLayoutConstraint?
}
