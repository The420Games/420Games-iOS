//
//  User.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 14..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class User: FTDataObject {
    
    var password: String?
    var email: String?
    var username: String!
    var athlete: Athlete?
    private var _backendlessUser: BackendlessUser?
    
    private let ftEmailBackendlessPropertyName = "email"
    private let ftUsernameBackendlessPropertyName = "username"
    private let ftAthleteBackendlessPropertyName = "athlete"
    private let ftCreatedBackendlessPropertyName = "created"
    
    private let ttNewUserTimeOut: NSTimeInterval = 100.0 //If user created within n seconds
    
    convenience init(backendlessUser: BackendlessUser) {
        
        self.init()
        
        self.objectId = backendlessUser.objectId
        
        if let email = backendlessUser.getProperty(ftEmailBackendlessPropertyName) as? String {
            self.email = email
        }
        
        if let username = backendlessUser.getProperty(ftUsernameBackendlessPropertyName) as? String {
            self.username = username
        }
        
        if let athlete = backendlessUser.getProperty(ftAthleteBackendlessPropertyName) as? Athlete {
            self.athlete = athlete
        }
        
        if let created = backendlessUser.getProperty(ftCreatedBackendlessPropertyName) as? NSDate {
            self.created = created
        }
        
        _backendlessUser = backendlessUser
    }
    
    func backendlessUser() -> BackendlessUser? {
        
        if let bUser = Backendless.sharedInstance().userService.currentUser {
            
            updateBackendlessUser(bUser)
            return bUser
        }
        
        return nil
        
    }
    
    func newUser() -> BackendlessUser {
        
        let bUser = BackendlessUser()
        updateBackendlessUser(bUser)
        
        return bUser
    }
    
    private func updateBackendlessUser(bUser: BackendlessUser) {
        
        var props = [String: AnyObject]()
        
        if self.email != nil {
            props[ftEmailBackendlessPropertyName] = self.email
        }
        
        if self.username != nil {
            props[ftUsernameBackendlessPropertyName] = self.username
        }
        
        if self.athlete != nil {
            props[ftAthleteBackendlessPropertyName] = self.athlete
            bUser.setProperty(ftAthleteBackendlessPropertyName, object: self.athlete)
        }
        
        bUser.updateProperties(props)
        
        if self.password != nil && !self.password!.isEmpty {
            bUser.password = self.password!
        }
    }
    
    override func saveInBackgroundWithBlock(completion: ((success: Bool, error: NSError?) -> ())?) {
        
        let bUser = backendlessUser()
        Backendless.sharedInstance().userService.update(bUser, response: { (backendlessUser) in
            
            let user = User(backendlessUser: backendlessUser)
            FTDataManager.sharedInstance.currentUser!.athlete = user.athlete
            
            completion?(success: true, error: nil)
            
        }) { (fault) in
            
            completion?(success: false, error: NSError.errorWithFault(fault))
        }
    }
    
    func isNew() -> Bool {
        
        if let created = self.created {
            let diff = -1 * created.timeIntervalSinceNow
            
            return diff <= ttNewUserTimeOut
        }
        
        return false
    }
    
    func updateProfileFromFacebook() {
        //Download the facebook avatar
        let accessToken = FBSDKAccessToken.currentAccessToken()
        let urlString = String(format: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", accessToken.tokenString)
        let pictureURL = NSURL(string: urlString)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration:config, delegate: nil, delegateQueue:nil)
        let task = session.dataTaskWithURL(pictureURL!, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if data != nil {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    FTDataManager.sharedInstance.uploadImageData(data, path: Athlete.profileImagePath, completion: { (fileName, error) in
                        
                        if fileName != nil && error == nil {
                            self.athlete!.profileImage = fileName!
                            self.saveInBackgroundWithBlock({ (success, error) in
                                if error != nil {
                                    print("Error saving user \(error)")
                                }
                            })
                        }
                        else {
                            print("Error uploading profile image \(error)")
                        }
                    })
                })
            }
        })
        task.resume()
    }

}
