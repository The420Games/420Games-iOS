//
//  Athlete.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

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

}
