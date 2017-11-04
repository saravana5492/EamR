//
//  myCartCell.swift
//  EamR
//
//  Created by Apple on 21/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class myCartCell: UITableViewCell {

    @IBOutlet var outerView: UIView!
    @IBOutlet var prodImage: UIImageView!
    @IBOutlet var prodName: UILabel!
    @IBOutlet var prodPrice: UILabel!
    @IBOutlet var minusProdBtn: UIButton!
    @IBOutlet var plusProdBtn: UIButton!
    @IBOutlet var prodQtyLbl: UILabel!
    @IBOutlet var deleteProdBtn: UIButton!
    @IBOutlet var prodDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
