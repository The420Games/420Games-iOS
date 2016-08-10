//
//  FTDataManager.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Kingfisher

let FTSignedOutNotificationName = "SignedOutNotification"

class FTDataManager: NSObject {
    
    static let sharedInstance = FTDataManager()
    
    static let ftStagingAppID           =   "75CDFBC2-96FF-33B8-FF06-C049BDA03500"
    static let ftStagingAppSecret       =   "BE90B76E-11F1-D8D2-FFFD-CA1ED696D300"
    static let ftStagingAppVersion      =   "v1"
    
    static let ftProductionAppID        =   ""
    static let ftProductionAppSecret    =   ""
    static let ftProductionAppVersion   =   "v1"
    
    static let ftStaging                =   true
    
    class func initBackend() {
        
        let appId = ftStaging ? ftStagingAppID : ftProductionAppID
        let appSecret = ftStaging ? ftStagingAppSecret : ftProductionAppSecret
        let version = ftStaging ? ftStagingAppVersion : ftProductionAppVersion
        
        let backendless = Backendless.sharedInstance()
        
        backendless.initApp(appId, secret:appSecret, version:version)
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = MediaService()
    }

    // MARK: - User
    
    private var _currentUser: User?
    var currentUser: User? {
        get {
            if _currentUser == nil {
                if let bUser = Backendless.sharedInstance().userService.currentUser {
                    _currentUser = User(backendlessUser: bUser)
                }
            }
            
            return _currentUser
        }
    }
    
    // MARK: - Email authentication
    
    func login(email: String, password: String, completion:((user: User?, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.login(email, password: password, response: {(backendlessUser : BackendlessUser!) -> () in
            
            completion?(user: self.currentUser, error: nil)
            
            },
                                                       error: {(fault : Fault!) -> () in
                                                        
                                                        completion?(user: nil, error: NSError.errorWithFault(fault))
            }
        )
    }
    
    func signup(user: User, completion:((success: Bool, error: NSError?) -> ())?) {
        
        let bUser = user.newUser()
        
        Backendless.sharedInstance().userService.registering(bUser, response: { (backendlessUser) in
            
            completion?(success: true, error: nil)
            
        }) { (fault) in
            completion?(success: false, error: NSError.errorWithFault(fault))
        }
    }
    
    func resetPassword(email: String, completion:((success: Bool, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.restorePassword(email, response: { (object) in
            
            completion?(success: true, error: nil)
            
        }) { (fault) in
            completion?(success: false, error: NSError.errorWithFault(fault))
        }
    }
    
    func logout(completion:((success: Bool, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.logout({ (response) in
            
            self._currentUser = nil
            
            completion?(success: true, error: nil)
            
        }) { (fault) in
            
            completion?(success: false, error: NSError.errorWithFault(fault))
        }
    }
    
    // MARK: - Images
    
    func uploadImage(image: UIImage, path: String, completion:((fileName: String?, error: NSError?) -> ())?) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.6)
        
        uploadImageData(imageData, path: path, completion: completion)
    }
    
    func uploadImageData(imageData:NSData!, path: String, completion:((fileName: String?, error: NSError?) -> ())?) {
        
        let fileName = NSUUID().UUIDString + ".jpg"
        let filePath = path + "/" + fileName
        
        Backendless.sharedInstance().fileService.upload(filePath, content: imageData, overwrite: true, response: { (file) in
            
            completion?(fileName: fileName, error: nil)
            
            }) { (fault) in
                completion?(fileName: nil, error: NSError.errorWithFault(fault))
        }
    }
    
    func backendFileServiceBaseURLString() -> String {
        
        let version = FTDataManager.ftStaging ? FTDataManager.ftStagingAppVersion : FTDataManager.ftProductionAppVersion
        let appId = (FTDataManager.ftStaging ? FTDataManager.ftStagingAppID : FTDataManager.ftProductionAppID).lowercaseString
        
        let urlString = "https://api.backendless.com/\(appId)/\(version)/files/"
        
        return urlString
    }
    
    func imageUrlForProperty(property: String?, path: String?) -> NSURL? {
        
        if property == nil {
            return nil
        }
        
        if let url = NSURL(string: property!) {
            if !url.scheme.isEmpty && url.host != nil {
                return url
            }
        }
        
        var urlString = backendFileServiceBaseURLString()
        if path != nil {
            urlString += path! + "/"
        }
        urlString += property!
        
        if let url = NSURL(string: urlString) {
            return url
        }
        
        return nil
    }
    
    func fetchImageWithURL(url:NSURL!, imageView: UIImageView!) {
        
        imageView.kf_setImageWithURL(url)
    }
    
    //MARK: - Facebook Login
    
    private func hasValidFacebookAccessToken() -> Bool {
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        return ((accessToken != nil) && (accessToken.expirationDate.compare(NSDate()) == NSComparisonResult.OrderedDescending))
    }
    
    private func loginToFacebook(completion:((accessToken:FBSDKAccessToken?, error:NSError?) -> Void)?) {
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.loginBehavior = FBSDKLoginBehavior.SystemAccount
        
        loginManager.logInWithReadPermissions(["email"], fromViewController: nil) { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            completion?(accessToken: result != nil ? result!.token : nil, error: error)
        }
    }
    
    private func loginWithFacebookAccessToken(accessToken:FBSDKAccessToken, completionBlock:((user: User?, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.setStayLoggedIn( true )
        Backendless.sharedInstance().userService.loginWithFacebookSDK(accessToken, fieldsMapping: ["email":"email", "name":"name"], response: { (user:BackendlessUser!) -> Void in
            
            let user = User(backendlessUser: user)
            
            self._currentUser = user
            
            completionBlock?(user: self.currentUser, error: nil)
            },
                                                                      error: { (fault:Fault!) -> Void in
                                                                        
                                                                        completionBlock?(user: nil, error: NSError.errorWithFault(fault))
        })
    }
    
    func loginWithFacebook(completion:((user: User?, error: NSError?) -> ())?) {
        
        //is our accessToken expired
        if (self.hasValidFacebookAccessToken()) {
            
            let accessToken = FBSDKAccessToken.currentAccessToken()
            self.loginWithFacebookAccessToken(accessToken, completionBlock: completion)
        }
        else {
            
            self.loginToFacebook({ (accessToken:FBSDKAccessToken?, error:NSError?) -> Void in
                
                if (accessToken != nil) {
                    self.loginWithFacebookAccessToken(accessToken!, completionBlock: completion)
                }
                else {
                    completion?(user:nil, error: error)
                }
            })
        }
    }
}
