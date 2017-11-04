//
//  purchHistCell.swift
//  EamR
//
//  Created by Apple on 24/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit

class purchHistCell: UITableViewCell {

    @IBOutlet var PurchImageView: UIImageView!
    @IBOutlet var purchProdName: UILabel!
    @IBOutlet var purchProdDesc: UILabel!
    @IBOutlet var purchProdPrice: UILabel!
    @IBOutlet var purchDate: UILabel!
    @IBOutlet weak var exhibitorName: UILabel!
    @IBOutlet weak var exhibitionName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
