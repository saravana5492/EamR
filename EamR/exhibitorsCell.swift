//
//  exhibitorsCell.swift
//  EamR
//
//  Created by Apple on 14/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class exhibitorsCell: UITableViewCell {

    @IBOutlet var exbiImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var countryLbl: UILabel!
    @IBOutlet var venuLbl: UILabel!
    @IBOutlet var descLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
