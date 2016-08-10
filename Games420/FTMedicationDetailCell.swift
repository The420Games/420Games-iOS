//
//  FTMedicationDetailCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 10..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTMedicationDetailCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(title: String, value: String) {
        
        titleLabel.text = title
        valueLabel.text = value
    }
    
    override func prepareForReuse() {
        
        titleLabel.text = nil
        valueLabel.text = nil
    }

}
