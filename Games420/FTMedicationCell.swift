//
//  FTMedicationCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTMedicationCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setupWithMedication(medication: Medication) {
     
        var title = ""
        if medication.activity != nil {
            
            if medication.activity!.name != nil {
                title += medication.activity!.name!
            }
            
            if medication.activity!.type != nil {
                
                if !title.isEmpty {
                    title += " "
                }
                title += medication.activity!.type!
            }
            
            if medication.activity!.startDate != nil {
                
                if !title.isEmpty {
                    title += " "
                }
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .ShortStyle
                formatter.timeStyle = .NoStyle
                
                title += formatter.stringFromDate(medication.activity!.startDate!)
            }
        }
        
        var subTitle = ""
        if medication.type != nil {
            subTitle += medication.type!
        }
        
        if medication.mood != nil {
            if let mood = MedicationMoodIndex(rawValue: medication.mood!.integerValue) {
                if !subTitle.isEmpty {
                    subTitle += " "
                }
                subTitle += "\(mood)"
            }
        }
        
        if medication.dosage != nil {
            
            if !subTitle.isEmpty {
                subTitle += " "
            }
            
            subTitle += "dosage: \(medication.dosage!)"
        }
        
        titleLabel.text = title
        subtitleLabel.text = subTitle
    }
}
