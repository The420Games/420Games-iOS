//
//  FTString.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 02..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

extension String {
    
    func validEmailFormat(strict: Bool = false) -> Bool
    {
        let stricterFilter = strict
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailRegex = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailTest.evaluateWithObject(self)
    }
}
