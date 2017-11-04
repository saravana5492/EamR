//
//  chatCell.swift
//  EamR
//
//  Created by Apple on 17/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class chatCell: UITableViewCell {

    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var chatListImageView: UIImageView!
    @IBOutlet weak var exhCompName: UILabel!
    @IBOutlet weak var exhCompLastMsg: UILabel!
    @IBOutlet weak var exhLastTime: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
