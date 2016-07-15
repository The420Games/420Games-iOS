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
    
    var appID = ""
    var clientSecret = ""
    private var token: String?
    private var callBackURLString: String?
    
    private let baseURL = "https://www.strava.com"
    private let apiPath = "/api/v3"
    private let athletePath = "/athlete"
    private let activitesPath = "/activities"
    
    private let oathPath = "/oauth"
    private let authorizationPath = "/authorize"
    private let tokenExchangePath = "/token"
    
    static let FTStravaAthleteAuthenticatedNotificationName = "FTStravaAthleteAuthenticatedNotification"
    
    var isAuthorized: Bool  {
        get {
            return self.token != nil
        }
    }
    
    func authorize(urlString: String!) {
        
        let stateInfo = ""
        
        self.callBackURLString = urlString
        
        let callBackUrl = NSURL(string: urlString)
        
        let urlString = NSString(format: baseURL + oathPath + authorizationPath + "?client_id=%ld&response_type=code&redirect_uri=%@&scope=write&state=%@&approval_prompt=force", 12445, callBackUrl!.absoluteString, stateInfo.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)
        
        if let url = NSURL(string: urlString as String) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func handleOpenURL(url: NSURL) -> Bool {
        
        if self.callBackURLString != nil && url.absoluteString.containsString(self.callBackURLString!) {
        
            let components = NSURLComponents(string: url.absoluteString)
            
            if let code = components?.queryItems?.filter({$0.name == "code"}).first {
                self.exchangeToken(code.value!)
            }
            
            return true
        }
        
        return false
    }
    
    func fetchActivities(completion: ((results: [Activity]?, error: NSError?) -> ())?) {
        
        let session = NSURLSession(configuration: customURLsessionConfiguration())
        
        let url = NSURL(string: baseURL + apiPath + athletePath + activitesPath)
        
        let task = session.dataTaskWithURL(url!) { (data, response, error) in
            if error != nil {
                completion?(results: nil, error: error)
            }
            else {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [AnyObject]
                    completion?(results: Activity.arrayFromJsonObjects(json) as? [Activity], error: nil)
                    
                } catch let error as NSError {
                    completion?(results: nil, error: error)
                }
            }
        }
        
        task.resume()
        
    }
    
    private func customURLsessionConfiguration() -> NSURLSessionConfiguration {
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        if isAuthorized {
            var headers = config.HTTPAdditionalHeaders
            if headers == nil {
                headers = [String: AnyObject]()
            }
            headers!["Authorization"] = "Bearer \(token!)"
            config.HTTPAdditionalHeaders = headers
        }
        
        return config
    }
    
    private func exchangeToken(code: String) {
        
        let url = NSURL(string: baseURL + oathPath + tokenExchangePath)
        let request = NSMutableURLRequest(URL: url!)

        request.HTTPMethod = "POST"
        
        let dataString = "client_id=\(appID)&client_secret=\(clientSecret)&code=\(code)"
        request.HTTPBody = dataString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String: AnyObject]
                if let accessToken = json["access_token"] as? String {
                    self.token = accessToken
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: self, userInfo: ["success": true])
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: self, userInfo: ["success": true])
                    })
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(FTStravaManager.FTStravaAthleteAuthenticatedNotificationName, object: self, userInfo: ["success": false])
                })
            }
            
        }
        
        task.resume()
        
    }
}
