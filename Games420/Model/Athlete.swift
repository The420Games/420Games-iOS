//
//  Athlete.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

enum GenderType : String {
    case Male = "M", Female = "F", NotProvided = ""
    static let allValues = [Male, Female, NotProvided]
}

class Athlete: FTDataObject {
    
    static let profileImagePath = "profileimages"
    
    var profileImage: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var locality: String?
    var state: String?
    var country: String?
    var source: String?
    var externalId: String?
    var bio: String?
    var birthDay: NSDate?
    
    override class func dataFromJsonObject(jsonObject: [String: AnyObject]!) -> FTDataObject {
        
        let athlete = Athlete()
        
        athlete.lastName = jsonObject["lastname"] as? String
        athlete.firstName = jsonObject["firstname"] as? String
        athlete.gender = jsonObject["sex"] as? String
        athlete.locality = jsonObject["city"] as? String
        athlete.state = jsonObject["state"] as? String
        athlete.country = jsonObject["country"] as? String
        
        if let id = jsonObject["id"] as? Int {
            athlete.externalId = String(id)
        }
        
        return athlete
    }
    
    func localizedGender() -> String {
        
        var ret = ""
        
        let maleString = NSLocalizedString("Male", comment: "Male gender title")
        let femaleString = NSLocalizedString("Female", comment: "Female gender title")
        
        if let genderStr = gender {
            
            if genderStr == "M" {
                ret = maleString
            }
            else if genderStr == "F" {
                ret = femaleString
            }
        }
        
        return ret        
    }

}
