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
let FTSignedInNotificationName = "SignedInNotification"
let FTUserUpdatedNotificationName = "UserUpdtedNotification"

class FTDataManager: NSObject {
    
    static let sharedInstance = FTDataManager()
    
    static let ftStagingAppID           =   "75CDFBC2-96FF-33B8-FF06-C049BDA03500"
    static let ftStagingAppSecret       =   "BE90B76E-11F1-D8D2-FFFD-CA1ED696D300"
    static let ftStagingAppVersion      =   "v1"
    
    static let ftProductionAppID        =   "34BDCD4C-6480-5F57-FFB1-C62CDB764400"
    static let ftProductionAppSecret    =   "23E146A6-FD34-13FB-FF92-57BC4E51EB00"
    static let ftProductionAppVersion   =   "v1"
    
    static let ftStaging                =   true
    
    class func initBackend() {
        
        let appId = ftStaging ? ftStagingAppID : ftProductionAppID
        let appSecret = ftStaging ? ftStagingAppSecret : ftProductionAppSecret
        let version = ftStaging ? ftStagingAppVersion : ftProductionAppVersion
        
        let backendless = Backendless.sharedInstance()
        
        backendless?.initApp(appId, secret:appSecret, version:version)
        // If you plan to use Backendless Media Service, uncomment the following line (iOS ONLY!)
        // backendless.mediaService = MediaService()
    }

    // MARK: - User
    
    fileprivate var _currentUser: User?
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
    
    func login(_ email: String, password: String, completion:((_ user: User?, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.login(email, password: password, response: {(backendlessUser) -> () in
            
            completion?(self.currentUser, nil)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: FTSignedInNotificationName), object: backendlessUser)
            
            FTAnalytics.identifyUser(backendlessUser?.objectId! as! String)
            
            },
                                                       error: {(fault) -> () in
                                                        
                                                        completion?(nil, NSError.errorWithFault(fault))
            }
        )
    }
    
    func signup(_ user: User, completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        let bUser = user.newUser()
        
        Backendless.sharedInstance().userService.registering(bUser, response: { (backendlessUser) in
            
            completion?(true, nil)
            
        }) { (fault) in
            completion?(false, NSError.errorWithFault(fault))
        }
    }
    
    func resetPassword(_ email: String, completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.restorePassword(email, response: { (object) in
            
            completion?(true, nil)
            
        }) { (fault) in
            completion?(false, NSError.errorWithFault(fault))
        }
    }
    
    func logout(_ completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.logout({ (response) in
            
            self._currentUser = nil
            
            completion?(true, nil)
            
        }) { (fault) in
            
            completion?(false, NSError.errorWithFault(fault))
        }
    }
    
    // MARK: - Images
    
    func uploadImage(_ image: UIImage, path: String, completion:((_ fileName: String?, _ error: NSError?) -> ())?) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.6)
        
        uploadImageData(imageData, path: path, completion: completion)
    }
    
    func uploadImageData(_ imageData:Data!, path: String, completion:((_ fileName: String?, _ error: NSError?) -> ())?) {
        
        let fileName = UUID().uuidString + ".jpg"
        let filePath = path + "/" + fileName
        
        Backendless.sharedInstance().fileService.upload(filePath, content: imageData, overwrite: true, response: { (file) in
            
            completion?(fileName, nil)
            
            }) { (fault) in
                completion?(nil, NSError.errorWithFault(fault))
        }
    }
    
    func backendFileServiceBaseURLString() -> String {
        
        let version = FTDataManager.ftStaging ? FTDataManager.ftStagingAppVersion : FTDataManager.ftProductionAppVersion
        let appId = (FTDataManager.ftStaging ? FTDataManager.ftStagingAppID : FTDataManager.ftProductionAppID).lowercased()
        
        let urlString = "https://api.backendless.com/\(appId)/\(version)/files/"
        
        return urlString
    }
    
    func imageUrlForProperty(_ property: String?, path: String?) -> URL? {
        
        if property == nil {
            return nil
        }
        
        if let url = URL(string: property!) {
            if !(url.scheme?.isEmpty)! && url.host != nil {
                return url
            }
        }
        
        var urlString = backendFileServiceBaseURLString()
        if path != nil {
            urlString += path! + "/"
        }
        urlString += property!
        
        if let url = URL(string: urlString) {
            return url
        }
        
        return nil
    }
    
    func fetchImageWithURL(_ url:URL!, imageView: UIImageView!) {
        
        imageView.kf.setImage(with: url)
    }
    
    //MARK: - Facebook Login
    
    fileprivate func hasValidFacebookAccessToken() -> Bool {
        
        let accessToken = FBSDKAccessToken.current()
        
        return ((accessToken != nil) && (accessToken!.expirationDate.compare(Date()) == ComparisonResult.orderedDescending))
    }
    
    fileprivate func loginToFacebook(_ completion:((_ accessToken:FBSDKAccessToken?, _ error:NSError?) -> Void)?) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.systemAccount
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: nil) { (result, error) in
            
            if error == nil {
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                completion?(fbloginresult.token, nil)
            }
            else {
                completion?(nil, error as NSError?)
            }
        }
    }
    
    fileprivate func loginWithFacebookAccessToken(_ accessToken:FBSDKAccessToken, completionBlock:((_ user: User?, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().userService.setStayLoggedIn( true )
        Backendless.sharedInstance().userService.login(withFacebookSDK: accessToken, fieldsMapping: ["email":"email", "name":"name"], response: { (user) -> Void in
            
            let user = User(backendlessUser: user!)
            
            self._currentUser = user
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: FTSignedInNotificationName), object: user)
            
            FTAnalytics.identifyUser(user.objectId!)
            
            completionBlock?(self.currentUser, nil)
            },
                                                                      error: { (fault) -> Void in
                                                                        
                                                                        completionBlock?(nil, NSError.errorWithFault(fault))
        })
    }
    
    func loginWithFacebook(_ completion:((_ user: User?, _ error: NSError?) -> ())?) {
        
        //is our accessToken expired
        if (self.hasValidFacebookAccessToken()) {
            
            let accessToken = FBSDKAccessToken.current()
            self.loginWithFacebookAccessToken(accessToken!, completionBlock: completion)
        }
        else {
            
            self.loginToFacebook({ (accessToken:FBSDKAccessToken?, error:NSError?) -> Void in
                
                if (accessToken != nil) {
                    self.loginWithFacebookAccessToken(accessToken!, completionBlock: completion)
                }
                else {
                    completion?(nil, error)
                }
            })
        }
    }
}
