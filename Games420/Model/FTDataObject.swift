//
//  FTDataObject.swift
//  Games420
//
//  Created by Adam Lovastyik on 2016. 07. 13..
//  Copyright © 2016. ScreamingBox. All rights reserved.
//

import Foundation

class FTDataObject: NSObject {
    
    var objectId: String?
    var created: Date?
    var updated: Date?
    var ownerId: String?
    
    override init() {
        
        super.init()
        
        if self.ofClass() != User.ofClass() {
            self.ownerId = FTDataManager.sharedInstance.currentUser?.objectId
        }
    }
    
    class func dataFromJsonObject(_ jsonObject: [String: AnyObject]!) -> FTDataObject {
        
        let object = FTDataObject()
        return object
    }
    
    class func arrayFromJsonObjects(_ array: [AnyObject]!) -> [FTDataObject] {
        
        let ret = [FTDataObject]()
        
        return ret
    }
    
    // MARK: - Retrieve
    
    class func findObjects(_ whereClause: String?, order: [AnyObject]?, offset: Int?, limit: Int?, completion:((_ objects: [AnyObject]?, _ error: NSError?) -> ())?) {
        
        let query = BackendlessDataQuery()
        query.whereClause = whereClause
        
        let options = QueryOptions()
        if offset != nil {
            options.offset = offset! as NSNumber!
        }
        if limit != nil {
            options.pageSize = limit! as NSNumber!
        }
        options.sortBy = order
        
        query.queryOptions = options
        
        let dataStore = self.dataStore()
        
        dataStore.find(query, response: { (collection) in
            
            if let objs = collection?.data {
                completion?(objs as [AnyObject]?, nil)
            }
            else {
                completion?(nil, nil)
            }
            
        }) { (fault) in
            completion?(nil, NSError.errorWithFault(fault))
        }
    }
    
    class func findObjects(_ whereClause: String?, order: [AnyObject]?, completion:((_ objects: [AnyObject]?, _ error: NSError?) -> ())?) {
        
        findObjects(whereClause, order: order, offset: nil, limit: nil, completion: completion)
    }
    
    class func findFirstObject(_ whereClause: String, completion:((_ object: AnyObject?, _ error: NSError?) -> ())?) {
        
        self.findObjects(whereClause, order: nil, offset: 0, limit: 1) { (objects, error) in
            if let firstObject = objects?.first {
                completion?(firstObject, nil)
            }
            else {
                completion?(nil, error)
            }
        }
    }
    
    // MARK: - Save and update
    
    func saveInBackgroundWithBlock(_ completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().persistenceService.of(self.ofClass()).save(self, response: { (object) in
            
            if let responseObject = object as? FTDataObject {
                self.objectId = responseObject.objectId
            }
            
            completion?(true, nil)
            
        }) { (fault) in
            completion?(false, NSError.errorWithFault(fault))
        }
    }
    
    func saveInBackground(_ completion:((_ object: FTDataObject?, _ error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().persistenceService.of(self.ofClass()).save(self, response: { (response) in
            
            if let responseObject = response as? FTDataObject {
                completion?(responseObject, nil)
            }
            else {
                completion?(nil, NSError(domain: "Backendless", code: -6668, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Return object missing type", comment: "Error when saving object")]))
            }
            
        }) { (fault) in
            completion?(nil, NSError.errorWithFault(fault))
        }
    }
    
    class func saveAllInBackground(_ objects: [FTDataObject], completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        let group = DispatchGroup();
        var successCount = 0
        let totalCount = objects.count
        
        for object in objects {
            
            group.enter()
            
            object.deleteInBackgroundWithBlock({ (success, error) in
                if success {
                    successCount += 1
                }
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            if successCount == totalCount {
                completion?(true, nil)
            }
            else {
                completion?(false, NSError(domain: "Backendless", code: -6668, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Some objects failed to delete", comment: "Error message when some objects failed to delete in a mass deletion")]))
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteInBackgroundWithBlock(_ completion:((_ success: Bool, _ error: NSError?) -> ())?) {
        
        if self.objectId == nil && self.objectId!.isEmpty {
            completion?(false, NSError(domain: "Backendless", code: -6667, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No objectid", comment: "Error message when object missing id")]))
        }
        else {
            Backendless.sharedInstance().persistenceService.of(self.ofClass()).removeID(self.objectId!, response: { (response) in
                
                completion?(true, nil)
                
                }, error: { (fault) in
                    completion?(false, NSError.errorWithFault(fault))
            })
        }
    }
    
    class func dataStore() -> IDataStore {
        
        let dataStore = Backendless.sharedInstance().persistenceService.of(self.classForCoder())
        
        return dataStore!
    }

}
