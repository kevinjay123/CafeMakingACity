//
//  InfoPanel.swift
//  GPSUtility
//
//  Created by Kevin Chan on 2016/11/17.
//  Copyright © 2016年 Kevinjay Chan. All rights reserved.
//

import UIKit
import Cosmos

class InfoPanel: UIView {

    @IBOutlet var starRatingView: [CosmosView]!
    @IBOutlet weak var infoPanelBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        for view in starRatingView {
            view.backgroundColor = .clear
            view.settings.fillMode = .half
            view.settings.updateOnTouch = false
        }
    }
}
