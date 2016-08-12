//
//  Activity.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

enum ActivityType: String {
    case Ride = "Ride", Run = "Run", Swim = "Swim", Hike = "Hike", Walk = "Walk"
    static let allValues = [Ride, Run, Swim, Hike, Walk]
    
    func icon() -> UIImage? {
        switch self {
        case .Ride: return UIImage(named: "icon_bike")
        case .Run: return UIImage(named: "icon_run")
        case .Swim: return UIImage(named: "icon_swim")
        case .Hike: return UIImage(named: "icon_hike")
        case .Walk: return UIImage(named: "icon_walk")
        default: return nil
        }
    }
    
    func localizedName(past: Bool) -> String {
        switch self {
        case .Ride: return past ? NSLocalizedString("biked", comment: "Bike past tense") : NSLocalizedString("bike", comment: "Bike continous")
        case .Run: return past ? NSLocalizedString("run", comment: "Run past tense") : NSLocalizedString("run", comment: "Run continous")
        case .Swim: return past ? NSLocalizedString("Swam", comment: "Swim past tense") : NSLocalizedString("swim", comment: "Swim continous")
        case .Hike: return past ? NSLocalizedString("hiked", comment: "Hike past tense") : NSLocalizedString("hike", comment: "Hiking continous")
        case .Walk: return past ? NSLocalizedString("walked", comment: "Walk past tense") : NSLocalizedString("walk", comment: "Walking continous")
        default: return "\(self)"
        }
    }
}

class Activity: FTDataObject {
    
    var activityId: String?
    var name: String?
    var type: String?
    var distance: NSNumber?
    var startDate: NSDate?
    var elapsedTime: NSNumber?
    var source: String?
    var elevationGain: NSNumber?
    
    private let ftAthleteProfileImagesPath = "profiles"
    
    override class func dataFromJsonObject(jsonObject: [String: AnyObject]!) -> Activity {
        
        let object = Activity()
        
        let id = jsonObject["id"] as! Int
        object.activityId = String(id)
        object.name = jsonObject["name"] as? String
        object.type = jsonObject["type"] as? String
        object.distance = jsonObject["distance"] as? NSNumber
        object.elapsedTime = jsonObject["elapsed_time"] as? NSNumber
        object.elevationGain = jsonObject["total_elevation_gain"] as? NSNumber
        
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
    
    class func isMetricSystem() -> Bool {
        
        if let value = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? NSNumber {
            return value.boolValue
        }
        
        return false
    }
    
    class func distanceUnit() -> String {
        
        return Activity.isMetricSystem() ? NSLocalizedString("km", comment: "km unit title") : NSLocalizedString("miles", comment: "Miles unit title")
    }
    
    func verboseDistance() -> String {
        
        let unit = Activity.distanceUnit()
        
        var dist = distance != nil ? distance!.doubleValue : 0.0
        
        if !Activity.isMetricSystem() {
            dist = dist / 1609.344
        }
        else {
            dist = dist / 1000
        }
        
        return String(format: "%.2f", dist) + " " + unit
        
    }
    
    func verboseDuration(textual: Bool) -> String {
        
        if elapsedTime != nil && elapsedTime!.doubleValue != 0.0 {
            
            let hours = (Double)((Int)(elapsedTime!.doubleValue / 3600.0))
            let mins = (Double)((Int)((elapsedTime!.doubleValue - (hours * 3600.0)) / 60))
            let secs = (Int)(elapsedTime!.doubleValue - (hours * 3600.0) - (mins * 60.0))
            
            var title = ""
            
            if textual {
                
                if hours > 0 {
                    title += String(format: "%.0f ", hours) + NSLocalizedString("hours", comment: "Hours")
                }
                
                if mins > 0 || (hours > 0 && secs > 0) {
                
                    if !title.isEmpty {
                        title += " "
                    }
                    
                    title += String(format: "%.0f ", mins) + NSLocalizedString("mins", comment: "Minutes short")
                }
                
                if secs > 0 {
                    
                    if !title.isEmpty {
                        title += " "
                    }
                    
                    title += String(format: "%.02d", secs) + " " + NSLocalizedString("secs", comment: "Seconds short")
                }
                
                return title
            }
            else {
                return "\(hours):\(mins):" + String(format: "%.02f", secs)
            }
        }
        else {
            return ""
        }
    }
}
