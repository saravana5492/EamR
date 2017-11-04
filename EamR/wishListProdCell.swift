//
//  wishListProdCell.swift
//  EamR
//
//  Created by Apple on 20/09/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class wishListProdCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var priceRange: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
