//
//  FTAnalytics.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 08. 16..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import Mixpanel

enum FTEvent: String {
    case Test = "test"
}

class FTAnalytics: NSObject {

    static private let mixpanelKey = "3f0d0950cb84e3458e628521ca4f7fab"
    
    class func initAnalytics() {
        
        _ = Mixpanel.sharedInstanceWithToken(mixpanelKey)
    }
    
    class func trackEvent(event: FTEvent, data: [String: AnyObject]?) {
        
        Mixpanel.sharedInstance().track(event.rawValue, properties: data)
    }
}
