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
    fileprivate var _backendlessUser: BackendlessUser?
    
    fileprivate let ftEmailBackendlessPropertyName = "email"
    fileprivate let ftUsernameBackendlessPropertyName = "username"
    fileprivate let ftAthleteBackendlessPropertyName = "athlete"
    fileprivate let ftCreatedBackendlessPropertyName = "created"
    
    fileprivate let ttNewUserTimeOut: TimeInterval = 100.0 //If user created within n seconds
    
    static let minimumPasswordLength = 6
    
    convenience init(backendlessUser: BackendlessUser) {
        
        self.init()
        
        self.objectId = backendlessUser.objectId as String?
        
        if let email = backendlessUser.getProperty(ftEmailBackendlessPropertyName) as? String {
            self.email = email
        }
        
        if let username = backendlessUser.getProperty(ftUsernameBackendlessPropertyName) as? String {
            self.username = username
        }
        
        if let athlete = backendlessUser.getProperty(ftAthleteBackendlessPropertyName) as? Athlete {
            self.athlete = athlete
        }
        
        if let created = backendlessUser.getProperty(ftCreatedBackendlessPropertyName) as? Date {
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
    
    fileprivate func updateBackendlessUser(_ bUser: BackendlessUser) {
        
        var props = [String: AnyObject]()
        
        if self.email != nil {
            props[ftEmailBackendlessPropertyName] = self.email as AnyObject?
        }
        
        if self.username != nil {
            props[ftUsernameBackendlessPropertyName] = self.username as AnyObject?
        }
        
        if self.athlete != nil {
            props[ftAthleteBackendlessPropertyName] = self.athlete
            bUser.setProperty(ftAthleteBackendlessPropertyName, object: self.athlete)
        }
        
        bUser.updateProperties(props)
        
        if self.password != nil && !self.password!.isEmpty {
            bUser.password = self.password! as NSString!
        }
    }
    
    override func saveInBackground(_ completion: ((_ object: FTDataObject?, _ error: NSError?) -> ())?) {
        
        let bUser = backendlessUser()
        Backendless.sharedInstance().userService.update(bUser, response: { (backendlessUser) in
            
            let user = User(backendlessUser: backendlessUser!)
            FTDataManager.sharedInstance.currentUser!.athlete = user.athlete
            
            completion?(user, nil)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: FTUserUpdatedNotificationName), object: user)
            
        }) { (fault) in
            
            completion?(nil, NSError.errorWithFault(fault))
        }
    }
    
    override func saveInBackgroundWithBlock(_ completion: ((_ success: Bool, _ error: NSError?) -> ())?) {
        
        saveInBackground { (object, error) in
            
            completion?(object != nil, error)
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
        let accessToken = FBSDKAccessToken.current()
        let urlString = String(format: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", (accessToken?.tokenString)!)
        let pictureURL = URL(string: urlString)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration:config, delegate: nil, delegateQueue:nil)
        let task = session.dataTask(with: pictureURL!, completionHandler: { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
            
            if data != nil {
                
                DispatchQueue.main.async(execute: {
                    
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
        } as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }

}
