//
//  GroupTableViewCell.swift
//  HomeSpace
//
//  Created by Admin on 26/09/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupItem: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.groupItem.setTitleColor(UIColor(red: 43/255, green: 152/255, blue: 240/255, alpha: 1.0), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        groupItem.layer.cornerRadius = 26
        
    }
}
