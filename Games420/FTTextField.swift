//
//  FTTextField.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

class FTTextField: UITextField {
    
    fileprivate let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    func ft_setup() {
        
        layer.borderColor = UIColor.ftMidGray().cgColor
        borderStyle = .none
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        backgroundColor = UIColor.clear
        
        tintColor = UIColor.white
        textColor = UIColor.white
        font = UIFont.defaultFont(.light, size: 13.0)
        
        keyboardAppearance = .dark
    }
    
    func ft_setPlaceholder(_ placeholder: String) {
        
        let attrPlcHolder = NSAttributedString(string: placeholder, attributes: [
            NSFontAttributeName: UIFont.defaultFont(.light, size: 13)!,
            NSForegroundColorAttributeName: UIColor.white
            ])
        
        self.attributedPlaceholder = attrPlcHolder
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
