//
//  FTSelectActivityCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTSelectActivityCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setupWithActivity(activity: Activity) {
        
        titleLabel.text = "\(activity.startDate) \(activity.name)"
        subtitleLabel.text = "Distance: \(activity.distance), duration: \(activity.elapsedTime)"
    }
}
