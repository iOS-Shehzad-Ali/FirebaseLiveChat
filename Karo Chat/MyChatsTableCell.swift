//
//  MyChatsTableCell.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 23/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

class MyChatsTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: DesignableImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userText: UILabel!
    
    @IBOutlet weak var messageTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
