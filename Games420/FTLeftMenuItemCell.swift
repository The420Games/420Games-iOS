//
//  FTLeftMenuItemCell.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTLeftMenuItemCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var horizontalLine: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.font = UIFont.defaultFont(.Bold, size: 15.0)
        titleLabel.textColor = UIColor.ftMidGray2()

        horizontalLine.backgroundColor = UIColor.ftMidGray2()
        
        contentView.backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
    }
    
    func setupCell(icon: UIImage, title: String, lastItem: Bool) {
        
        iconImageView.image = icon
        titleLabel.text = title
        horizontalLine.hidden = lastItem
    }
}
