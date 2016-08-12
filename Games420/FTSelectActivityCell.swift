//
//  FTSelectActivityCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTSelectActivityCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = UIFont.defaultFont(.Medium, size: 16)
        titleLabel.textColor = UIColor.whiteColor()
        
        subtitleLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        subtitleLabel.textColor = UIColor.whiteColor()
        
        separatorView.backgroundColor = UIColor.ftMidGray()
    }
    
    private func populateDate(date: NSDate?) {
        
        if date != nil {
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Hour, .Minute, .Year, .Month, .Day], fromDate: date!)
            let month = components.month
            let day = components.day
            
            let attrDate = NSMutableAttributedString(string: String(format: "%02d", month), attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.defaultFont(.Light, size: 12.0)!
                ])
            attrDate.appendAttributedString(NSAttributedString(string: "\n"))
            attrDate.appendAttributedString(NSAttributedString(string: String(format: "%02d", day), attributes: [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont.defaultFont(.Bold, size: 12.0)!
                ]))
            dateLabel.attributedText = attrDate
        }
        else {
            dateLabel.text = ""
        }
    }
    
    func setupWithActivity(activity: Activity, lastItem: Bool) {
        
        var title = ""
        if activity.name != nil && !activity.name!.isEmpty  {
            title += activity.name!
        }
        else {
            title += NSLocalizedString("Distance", comment: "Distance") + ":"
        }
        
        if !title.isEmpty {
            title += " "
        }
        
        title += activity.verboseDistance()
        
        titleLabel.text = title
        subtitleLabel.text = NSLocalizedString("Duration", comment: "Duration") + ": " + activity.verboseDuration(true)
        
        iconImageView.image = nil
        if activity.type != nil {
            if let type = ActivityType(rawValue: activity.type!) {
                iconImageView.image = type.icon()
            }
        }
        
        populateDate(activity.startDate)
        
        separatorView.hidden = lastItem
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        subtitleLabel.text = ""
        iconImageView.image = nil
        dateLabel.text = ""
    }
}
