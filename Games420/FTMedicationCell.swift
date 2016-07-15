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
     
        titleLabel.text = "\(medication.activity?.name) \(medication.activity?.type) \(medication.activity?.startDate)"
        subtitleLabel.text = "\(medication.type) \(medication.dosage) \(medication.mood != nil ? MedicationMoodIndex(rawValue: medication.mood!.integerValue) : nil)"
    }
}
