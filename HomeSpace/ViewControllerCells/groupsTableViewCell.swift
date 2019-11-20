//
//  groupsTableViewCell.swift
//  HomeSpace
//
//  Created by axom1234 on 26/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class groupsTableViewCell: UITableViewCell {

    @IBOutlet weak var groupItem: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupItem.layer.cornerRadius = 26
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        groupItem.layer.cornerRadius = 26

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
