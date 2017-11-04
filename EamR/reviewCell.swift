//
//  reviewCell.swift
//  EamR
//
//  Created by Apple on 14/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import FloatRatingView

class reviewCell: UITableViewCell {

    @IBOutlet var reviewImageView: UIImageView!
    @IBOutlet var reviewText: UILabel!
    @IBOutlet var reviewerName: UILabel!
    @IBOutlet var revieweHead: UILabel!
    @IBOutlet var starRating: FloatRatingView!
    
    @IBOutlet var reviewDate: UILabel!
    //@IBOutlet var starRating: ASStarRatingView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
