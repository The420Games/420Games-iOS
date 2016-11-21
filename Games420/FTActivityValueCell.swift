//
//  FTMoodValueCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 15..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTActivityValueCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var colorBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.defaultFont(.light, size: 13)
        titleLabel.textColor = UIColor.white
        
        valueLabel.font = UIFont.defaultFont(.bold, size: 26)
        valueLabel.textColor = UIColor.white
    }
    
    func setupCell(_ activityType: ActivityType, value: Int) {
    
        iconImageView.image = activityType.icon()
        titleLabel.text = activityType.localizedName(false)
        colorBarView.backgroundColor = activityType.color()
        valueLabel.text = "\(value)"
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        colorBarView.backgroundColor = UIColor.clear
        
        titleLabel.text = ""
        valueLabel.text = ""
    }
}
