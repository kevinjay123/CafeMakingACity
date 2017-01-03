//
//  RatingCell.swift
//  CoffeeViewer
//
//  Created by Kevin Chan on 2016/12/30.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import UIKit
import Cosmos

class RatingCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        starView.settings.updateOnTouch = false
        starView.settings.fillMode = .half
        starView.backgroundColor = .clear
    }
}
