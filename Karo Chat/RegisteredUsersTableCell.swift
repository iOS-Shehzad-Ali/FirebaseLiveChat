//
//  RegisteredUsersTableCell.swift
//  Karo Chat
//
//  Created by Shehzad Ali on 12/05/17.
//  Copyright © 2017 Shehzad Ali. All rights reserved.
//

import UIKit

class RegisteredUsersTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
