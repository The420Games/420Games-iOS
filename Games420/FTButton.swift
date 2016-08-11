//
//  FTButton.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

extension UIButton {
    
    func ft_setupButton(bgColor: UIColor, title: String) {
        
        backgroundColor = bgColor
        
        clipsToBounds = true
        layer.cornerRadius = 5.0
        
        setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleLabel?.font = UIFont.defaultFont(.Bold, size: 14.7)
        setTitle(title, forState: .Normal)
    }
    
    func ft_setupCheckBox() {
        
        setTitle(nil, forState: .Normal)
        setTitle(nil, forState: .Selected)
        
        setImage(UIImage(named: "btn_checkbox-normal"), forState: .Normal)
        setImage(UIImage(named: "btn_checkbox-checked"), forState: .Selected)
    }
    
    func ft_setChecked(checked: Bool) {
        
        self.selected = checked
    }
    
    func ft_Checked() -> Bool {
        return self.selected
    }
}
