//
//  FTNavigationItem.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 11..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    func addEmptyBackButton(target: AnyObject, action: Selector) {
        
        hidesBackButton = true
        
        let button = UIBarButtonItem(image: UIImage(named: "btn_back"), style: .Plain, target: target, action: action)
        leftBarButtonItem = button
    }
    
}