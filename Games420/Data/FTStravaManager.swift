//
//  FTStravaManager.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 12..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

class FTStravaManager: NSObject {

    static let sharedInstance = FTStravaManager()
    
    let ftStravaSourceId = "Strava"
    
    var appID = ""
    var clientSecret = ""
    fileprivate var token: String?
    fileprivate var callBackURLString: String?
    
    fileprivate let baseURL = "https://www.strava.com"
    fileprivate let apiPath = "/api/v3"
    fileprivate let athletePath = "/athlete"
    fileprivate let athletesPath = "/athletes"
    fileprivate let activitesPath = "/activities"
    
    fileprivate let oathPath = "/oauth"
    fileprivate let authorizationPath = "/authorize"
    fileprivate let tokenExchangePath = "/token"
    
    static let FTStravaAthleteAuthenticatedNotificationName = "FTStravaAthleteAuthenticatedNotification"
    
    var isAuthorized: Bool  {
        get {
            return self.token != nil
        }
    }
    
    var updateAthleteWhenAuhtorized = true
    
    func authorize(_ urlString: String!) {
        
        let stateInfo = ""
        
        self.callBackURLString = urlString
        
        let callBackUrl = URL(string: urlString)
        
        let format = baseURL + oathPath + authorizationPath + "?client_id=%ld&response_type=code&redirect_uri=%@&scope=write&state=%@&approval_prompt=force"
        
        let urlString = NSString(format: format as NSString, 12445, callBackUrl!.absoluteString, stateInfo)
        
        if let url = URL(string: urlString as String) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func handleOpenURL(_ url: URL) -> Bool {
        
        if self.callBackURLString != nil && url.absoluteString.contains(self.callBackURLString!) {
        
            let components = URLComponents(string: url.absoluteString)
            
            if let code = components?.queryItems?.filter({$0.name == "code"}).first {
                self.exchangeToken(code.value!)
            }
            
            return true
        }
        
        return false
    }
    
    func fetchActivities(_ offset: Int, pageSize: Int, completion: ((_ results: [Activity]?, _ error: NSError?) -> ())?) {
        
        let session = URLSession(configuration: customURLsessionConfiguration())
        
        var urlString = baseURL + apiPath + athletePath + activitesPath
        
        if pageSize > 0 {
            urlString += "?page=\(offset + 1)&per_page=\(pageSize)"
        }
        
        let url = URL(string: urlString)
        
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                completion?(nil, error as NSError?)
            }
            else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [AnyObject]
                    completion?(Activity.arrayFromJsonObjects(json, source: self.ftStravaSourceId) as? [Activity], nil)
                    
                } catch let error as NSError {
                    completion?(nil, error)
                }
            }
        }) 
        
        task.resume()
        
    }
    
    fileprivate func customURLsessionConfiguration() -> URLSessionConfiguration {
        
        let config = URLSessionConfiguration.default
        if isAuthorized {
            var headers = config.httpAdditionalHeaders
            if headers == nil {
                headers = [String: AnyObject]()
            }
            headers!["Authorization"] = "Bearer \(token!)"
            config.httpAdditionalHeaders = headers
        }
        
        return config
    }
    
    fileprivate func exchangeToken(_ code: String) {
        
        let url = URL(string: baseURL + oathPath + tokenExchangePath)
        let request = NSMutableURLRequest(url: url!)

        request.httpMethod = "POST"
        
        let dataString = "client_id=\(appID)&client_secret=\(clientSecret)&code=\(code)"
        request.httpBody = dataString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                if let accessToken = json["access_token"] as? String {
                    self.token = accessToken
                    
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: self, userInfo: ["success": true])
                    })
                }
                else {
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: self, userInfo: ["success": true])
                    })
                }
                
                if let athleteJson = json["athlete"] as? [String : AnyObject] {
                    
                    if self.updateAthleteWhenAuhtorized && FTDataManager.sharedInstance.currentUser?.athlete == nil {
                    
                        self.updateUserAthlete(athleteJson)
                    }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: FTStravaManager.FTStravaAthleteAuthenticatedNotificationName), object: self, userInfo: ["success": false])
                })
            }
            
        }) 
        
        task.resume()
        
    }
    
    func fetchAthleteProfileImage(_ athleteData: [String: AnyObject], completion: ((_ image: UIImage?, _ error: NSError?) -> ())?) {
        
        var urlString: String?
        
        if let url = athleteData["profile"] as? String {
            urlString = url
        }
        else if let url = athleteData["profile_medium"] as? String {
            urlString = url
        }
        
        if urlString != nil && !urlString!.isEmpty {
            
            if let url = URL(string: urlString!) {
                
                let session = URLSession(configuration: customURLsessionConfiguration())
                
                let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    if data != nil {
                        if let image = UIImage(data: data!) {
                            completion?(image, nil)
                        }
                        else {
                            completion?(nil, nil)
                        }
                    }
                    else {
                        completion?(nil, error as NSError?)
                    }
                }) 
                
                task.resume()
            }
        }
        else {
            completion?(nil, nil)
        }
    }
    
    fileprivate func updateUserAthlete(_ athleteJson: [String: AnyObject]) {
        
        let athlete = Athlete.dataFromJsonObject(athleteJson) as! Athlete
        athlete.source = self.ftStravaSourceId
        
        let group = DispatchGroup();
        
        group.enter()
        
        self.fetchAthleteProfileImage(athleteJson, completion: { (image, error) in
            
            if image != nil {
                
                DispatchQueue.main.async(execute: {
                    
                    FTDataManager.sharedInstance.uploadImage(image!, path: Athlete.profileImagePath, completion: { (fileName, error) in
                        
                        if fileName != nil {
                            athlete.profileImage = fileName
                        }
                        
                        group.leave()
                    })
                })
            }
            else {
                group.leave()
            }
        })
        
        group.notify(queue: DispatchQueue.main, execute: {
            
            FTDataManager.sharedInstance.currentUser!.athlete = athlete
            FTDataManager.sharedInstance.currentUser!.saveInBackground({ (object, error) in
                if object != nil {
                    athlete.objectId = (object as! User).athlete?.objectId
                }
            })
        })
    }
    
    func fetchAthlete(_ athleteId: String?, completion: ((_ athleteData: [String: AnyObject]?, _ error: NSError?) -> ())?) {

        let session = URLSession(configuration: customURLsessionConfiguration())
        
        let url = URL(string: baseURL + apiPath + (athleteId != nil ? athletesPath + "/\(athleteId!)" : athletePath))
        
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                completion?(nil, error as NSError?)
            }
            else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    completion?(json, nil)
                    
                } catch let error as NSError {
                    completion?(nil, error)
                }
            }
        }) 
        
        task.resume()        
    }
}
