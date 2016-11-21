//
//  FTMedicationListCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTMedicationListCell: UITableViewCell {
    
    @IBOutlet weak var moodImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.defaultFont(.medium, size: 16)
        titleLabel.textColor = UIColor.white
        
        durationLabel.font = UIFont.defaultFont(.light, size: 13.0)
        durationLabel.textColor = UIColor.white
        
        dosageLabel.font = UIFont.defaultFont(.light, size: 13.0)
        dosageLabel.textColor = UIColor.white
        
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(_ medication: Medication, lastItem: Bool) {
    
        var title = NSLocalizedString("Distance", comment: "Distance prefix")
        
        title += " "
        
        if let activity = medication.activity {
            
            if let typeString = activity.type {
                if let type = ActivityType(rawValue: typeString) {
                    title += type.localizedName(true).capitalizingFirstLetter()
                }
            }
            
            title += ": "
            
            title += activity.verboseDistance()
            
            titleLabel.text = title
            
            durationLabel.text = NSLocalizedString("Duration", comment: "Duration label") + ": " + activity.verboseDuration(true)
            
            populateDate(activity.startDate as Date?)
        }
        else {
            titleLabel.text = ""
            dateLabel.text = ""
        }
        
        dosageLabel.text = NSLocalizedString("Dosage: ", comment: "Dosage title") + (medication.dosage != nil ? String(format: "%.01f", medication.dosage!.doubleValue) : NSLocalizedString("None", comment: "None label"))
        
        var moodStr = "icon_mood-0"
        if medication.mood != nil {
            if let mood = MedicationMoodIndex(rawValue: medication.mood!.intValue) {
                moodStr = "icon_mood-\(mood.rawValue)"
            }
        }
        moodImageView.image = UIImage(named: moodStr)
        
        separatorView.isHidden = lastItem
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        dosageLabel.text = ""
        moodImageView.image = nil
        durationLabel.text = ""
        dateLabel.text = ""
    }
}
