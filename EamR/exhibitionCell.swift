//
//  exhibitionCell.swift
//  EamR
//
//  Created by Apple on 14/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class exhibitionCell: UITableViewCell {

    
    @IBOutlet var exbImageView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var countryLbl: UILabel!
    @IBOutlet var venuLbl: UILabel!
    @IBOutlet var industryLbl: UILabel!
    @IBOutlet var descTV: UITextView!
    @IBOutlet var startDateLbl: UILabel!
    @IBOutlet var newDistLbl: UILabel!
    @IBOutlet var payStatusImg: UIImageView!
    @IBOutlet var removeBtn: UIButton!
    @IBOutlet var endDateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
