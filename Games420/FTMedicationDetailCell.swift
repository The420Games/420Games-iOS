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
    @IBOutlet weak var valueLeading: NSLayoutConstraint!
    
    @IBOutlet weak var valueImageView: UIImageView!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
        
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        titleLabel.font = UIFont.defaultFont(.Medium, size: 13.0)
        titleLabel.textColor = UIColor.whiteColor()
        
        valueLabel.font = UIFont.defaultFont(.Light, size: 13.0)
        valueLabel.textColor = UIColor.whiteColor()
        
        separatorLine.backgroundColor = UIColor.ftMidGray()
        separatorHeight.constant = 0.5
    }

    func configureCell(title: String, value: String, icon: UIImage?) {
        
        titleLabel.text = title
        valueLabel.text = value
        
        valueImageView.image = icon
        imageViewWidth.constant = icon != nil ? 30.0 : 0.0
        valueLeading.constant = icon != nil ? 10.0 : 0.0
    }
    
    override func prepareForReuse() {
        
        titleLabel.text = nil
        valueLabel.text = nil
        valueImageView.image = nil
    }

}
