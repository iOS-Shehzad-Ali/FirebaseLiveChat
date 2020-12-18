//
//  DesignableImageView.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 14/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

@IBDesignable class DesignableImageView: UIImageView {
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
