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
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.defaultFont(.medium, size: 16)
        titleLabel.textColor = UIColor.white
        
        subtitleLabel.font = UIFont.defaultFont(.light, size: 13.0)
        subtitleLabel.textColor = UIColor.white
        
        separatorView.backgroundColor = UIColor.ftMidGray()
    }
    
    fileprivate func populateDate(_ date: Date?) {
        
        if date != nil {
            
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.hour, .minute, .year, .month, .day], from: date!)
            let month = components.month
            let day = components.day
            
            let attrDate = NSMutableAttributedString(string: String(format: "%02d", month!), attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.defaultFont(.light, size: 12.0)!
                ])
            attrDate.append(NSAttributedString(string: "\n"))
            attrDate.append(NSAttributedString(string: String(format: "%02d", day!), attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont.defaultFont(.bold, size: 12.0)!
                ]))
            dateLabel.attributedText = attrDate
        }
        else {
            dateLabel.text = ""
        }
    }
    
    func setupWithActivity(_ activity: Activity, lastItem: Bool) {
        
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
        
        populateDate(activity.startDate as Date?)
        
        separatorView.isHidden = lastItem
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        subtitleLabel.text = ""
        iconImageView.image = nil
        dateLabel.text = ""
    }
}
