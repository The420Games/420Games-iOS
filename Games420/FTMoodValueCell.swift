//
//  FTMoodValueCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 15..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTMoodValueCell: UICollectionViewCell {
    
    @IBOutlet weak var colorBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = UIFont.defaultFont(.Light, size: 13)
        titleLabel.textColor = UIColor.whiteColor()
        
        valueLabel.font = UIFont.defaultFont(.Bold, size: 26)
        valueLabel.textColor = UIColor.whiteColor()
    }
    
    func setupCell(mood: MedicationMoodIndex, value: Int) {
    
        titleLabel.text = mood.localizedString()
        colorBarView.backgroundColor = mood.colorValue()
        valueLabel.text = "\(value)"
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        colorBarView.backgroundColor = UIColor.clearColor()
        
        titleLabel.text = ""
        valueLabel.text = ""
    }
}
