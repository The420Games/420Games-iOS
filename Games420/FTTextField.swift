//
//  FTTextField.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

class FTTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    func ft_setup() {
        
        layer.borderColor = UIColor.ftMidGray().CGColor
        borderStyle = .None
        clipsToBounds = true
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        backgroundColor = UIColor.clearColor()
        
        tintColor = UIColor.whiteColor()
        textColor = UIColor.whiteColor()
        font = UIFont.defaultFont(.Light, size: 13.0)
        
        keyboardAppearance = .Dark
    }
    
    func ft_setPlaceholder(placeholder: String) {
        
        let attrPlcHolder = NSAttributedString(string: placeholder, attributes: [
            NSFontAttributeName: UIFont.defaultFont(.Light, size: 13)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ])
        
        self.attributedPlaceholder = attrPlcHolder
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}