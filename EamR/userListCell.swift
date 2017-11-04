//
//  userListCell.swift
//  EamR
//
//  Created by Apple on 25/09/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class userListCell: UITableViewCell {

    @IBOutlet weak var userListBackView: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
