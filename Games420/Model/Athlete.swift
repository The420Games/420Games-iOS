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
    
    static let femaleValues = ["F", "FEMALE"]
    static let maleValues = ["M", "MALE"]
    
    func localizedString() -> String {
        
        switch self {
        case .Male: return NSLocalizedString("Male", comment: "Male title")
        case .Female: return NSLocalizedString("Female", comment: "Female title")
        case .NotProvided: return NSLocalizedString("Not provided", comment: "Not provided")
        default: return "\(self)"
        }
    }
    
    static func fromString(value: String) -> GenderType? {
        
        if let ret = GenderType(rawValue: value) {
            return ret
        }
        else {
            
            let maleIndex = maleValues.indexOf(value.uppercaseString)
            let femaleIndex = femaleValues.indexOf(value.uppercaseString)
            
            if maleIndex != NSNotFound {
                return .Male
            }
            else if femaleIndex != NSNotFound {
                return .Female
            }
        }
        
        return nil
    }
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
        
        if let genderValue = getGender() {
            return genderValue.localizedString()
        }
        
        return ""
    }

    func fullName() -> String {
        if (firstName == nil || firstName!.isEmpty) && (lastName == nil || lastName!.isEmpty) {
            return NSLocalizedString("Name not set", comment: "Name placeholder")
        }
        else {
            return "\(lastName != nil && !lastName!.isEmpty ? lastName! : "")\(lastName != nil && !lastName!.isEmpty ? ", " : "")\(firstName != nil ? firstName! : "")"
        }
    }
    
    func fullLocality() -> String {
        
        var title = ""
        
        if country != nil && !country!.isEmpty {
            title += country!
        }
        
        if state != nil && !state!.isEmpty {
            if !title.isEmpty {
                title += ", "
            }
            
            title += state!
        }
        
        if locality != nil && !locality!.isEmpty {
            if !title.isEmpty {
                title += ", "
            }
            
            title += locality!
        }
        
        return title.isEmpty ? NSLocalizedString("Not set", comment: "Locality placeholder") : title
    }
    
    func getGender() -> GenderType? {
        
        if gender != nil {
            return GenderType.fromString(gender!)
        }
        
        return nil
    }
}
