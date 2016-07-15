//
//  FTError.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

extension NSError {
    
    class func errorWithFault(fault: Fault) -> NSError {
        
        let codeString = NSString(string: fault.faultCode)
        let code = codeString.integerValue
        let desc = fault.description.isEmpty ? fault.description : NSLocalizedString("Unknown error", comment: "Unknown error description")
        
        let error = NSError(domain: "Backendless", code: code, userInfo:[NSLocalizedDescriptionKey: desc])
        
        return error
        
    }
    
}
