//
//  FTButton.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

extension UIButton {
    
    func ft_setupButton(_ bgColor: UIColor, title: String) {
        
        backgroundColor = bgColor
        
        clipsToBounds = true
        layer.cornerRadius = 5.0
        
        setTitleColor(UIColor.white, for: UIControlState())
        titleLabel?.font = UIFont.defaultFont(.bold, size: 14.7)
        setTitle(title, for: UIControlState())
    }
    
    func ft_setupCheckBox() {
        
        setTitle(nil, for: UIControlState())
        setTitle(nil, for: .selected)
        
        setImage(UIImage(named: "btn_checkbox-normal"), for: UIControlState())
        setImage(UIImage(named: "btn_checkbox-checked"), for: .selected)
    }
    
    func ft_setChecked(_ checked: Bool) {
        
        self.isSelected = checked
    }
    
    func ft_Checked() -> Bool {
        return self.isSelected
    }
}
