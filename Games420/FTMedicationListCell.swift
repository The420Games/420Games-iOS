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

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = UIFont.defaultFont(.Medium, size: 16)
        titleLabel.textColor = UIColor.whiteColor()
        
        durationLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        durationLabel.textColor = UIColor.whiteColor()
        
        dosageLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        dosageLabel.textColor = UIColor.whiteColor()
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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(medication: Medication) {
    
        var title = NSLocalizedString("Distance", comment: "Distance prefix")
        
        title += " "
        
        if let activity = medication.activity {
            
            if let typeString = activity.type {
                if let type = ActivityType(rawValue: typeString) {
                    switch type {
                    case .Ride: title += NSLocalizedString("biked", comment: "Bike past tense")
                    case .Run: title += NSLocalizedString("run", comment: "Run past tense")
                    case .Swim: title += NSLocalizedString("Swam", comment: "Swim past tense")
                    default: title += "\(type)"
                    }
                }
            }
            
            title += ": "
            
            title += activity.verboseDistance()
            
            titleLabel.text = title
            
            durationLabel.text = NSLocalizedString("Duration", comment: "Duration label") + ": " + activity.verboseDuration(true)
            
            populateDate(activity.startDate)
        }
        else {
            titleLabel.text = ""
            dateLabel.text = ""
        }
        
        dosageLabel.text = NSLocalizedString("Dosage: ", comment: "Dosage title") + (medication.dosage != nil ? String(format: "%.01f", medication.dosage!.doubleValue) : NSLocalizedString("None", comment: "None label"))
        
        var moodStr = "icon_mood-0"
        if medication.mood != nil {
            if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                moodStr = "icon_mood-\(mood.rawValue)"
            }
        }
        moodImageView.image = UIImage(named: moodStr)
    }
}
