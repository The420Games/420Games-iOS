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
        
        var title = ""
        if activity.name != nil {
            title += activity.name!
        }
        
        if activity.type != nil {
            
            if !title.isEmpty {
                title += " "
            }
            title += activity.type!
        }
        
        if activity.startDate != nil {
            
            if !title.isEmpty {
                title += " "
            }
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            
            title += formatter.stringFromDate(activity.startDate!)
        }
        
        var subTitle = ""
        if activity.distance != nil {
            subTitle += "Distance: \(activity.distance!.doubleValue / 1000) km"
        }
        
        if activity.elapsedTime != nil {
            if !subTitle.isEmpty {
                subTitle += " "
            }
            let hours = (Double)((Int)(activity.elapsedTime!.doubleValue / 3600.0))
            let mins = (Double)((Int)((activity.elapsedTime!.doubleValue - (hours * 3600.0)) / 60))
            let secs = (Int)(activity.elapsedTime!.doubleValue - (hours * 3600.0) - (mins * 60.0))
            subTitle += " duration: \(hours):\(mins):\(secs) "
        }
        
        titleLabel.text = title
        subtitleLabel.text = subTitle
    }
}
