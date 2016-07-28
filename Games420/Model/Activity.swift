//
//  Activity.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

class Activity: FTDataObject {
    
    var activityId: String?
    var name: String?
    var type: String?
    var distance: NSNumber?
    var startDate: NSDate?
    var elapsedTime: NSNumber?
    var source: String?
    
    private let ftAthleteProfileImagesPath = "profiles"
    
    override class func dataFromJsonObject(jsonObject: [String: AnyObject]!) -> Activity {
        
        let object = Activity()
        
        let id = jsonObject["id"] as! Int
        object.activityId = String(id)
        object.name = jsonObject["name"] as? String
        object.type = jsonObject["type"] as? String
        object.distance = jsonObject["distance"] as? NSNumber
        object.elapsedTime = jsonObject["elapsed_time"] as? NSNumber
        
        if let dateStr = jsonObject["start_date"] as? String {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
            object.startDate = formatter.dateFromString(dateStr)
        }
        
        return object
    }

    override class func arrayFromJsonObjects(array: [AnyObject]!) -> [FTDataObject] {
        
        return arrayFromJsonObjects(array, source: nil)
    }
    
    class func arrayFromJsonObjects(array: [AnyObject]!, source: String?) -> [FTDataObject] {
        
        var ret = [Activity]()
        
        for object in array {
            let activity = Activity.dataFromJsonObject(object as! [String: AnyObject])
            activity.source = source
            ret.append(activity)
        }
        
        return ret
    }
    
    override var description: String {
        return "[\(self.dynamicType): activityId=\(activityId), name=\(name), type=\(type), distance=\(distance), startDate=\(startDate), elapsedTime=\(elapsedTime), source=\(source)]\n"
    }
}
