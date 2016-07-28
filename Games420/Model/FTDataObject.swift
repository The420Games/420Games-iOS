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
    var created: NSDate?
    var updated: NSDate?
    var ownerId: String?
    
    override init() {
        
        super.init()
        
        if self.ofClass() != User.ofClass() {
            self.ownerId = FTDataManager.sharedInstance.currentUser?.objectId
        }
    }
    
    class func dataFromJsonObject(jsonObject: [String: AnyObject]!) -> FTDataObject {
        
        let object = FTDataObject()
        return object
    }
    
    class func arrayFromJsonObjects(array: [AnyObject]!) -> [FTDataObject] {
        
        let ret = [FTDataObject]()
        
        return ret
    }
    
    // MARK: - Retrieve
    
    class func findObjects(whereClause: String?, order: [AnyObject]?, offset: Int?, limit: Int?, completion:((objects: [AnyObject]?, error: NSError?) -> ())?) {
        
        let query = BackendlessDataQuery()
        query.whereClause = whereClause
        
        let options = QueryOptions()
        if offset != nil {
            options.offset = offset!
        }
        if limit != nil {
            options.pageSize = limit!
        }
        options.sortBy = order
        
        query.queryOptions = options
        
        let dataStore = self.dataStore()
        
        dataStore.find(query, response: { (collection) in
            
            let objs = collection.data
            completion?(objects: objs, error: nil)
            
        }) { (fault) in
            completion?(objects: nil, error: NSError.errorWithFault(fault))
        }
    }
    
    class func findObjects(whereClause: String?, order: [AnyObject]?, completion:((objects: [AnyObject]?, error: NSError?) -> ())?) {
        
        findObjects(whereClause, order: order, offset: nil, limit: nil, completion: completion)
    }
    
    class func findFirstObject(whereClause: String, completion:((object: AnyObject?, error: NSError?) -> ())?) {
        
        self.findObjects(whereClause, order: nil, offset: 0, limit: 1) { (objects, error) in
            if let firstObject = objects?.first {
                completion?(object: firstObject, error: nil)
            }
            else {
                completion?(object: nil, error: error)
            }
        }
    }
    
    // MARK: - Save and update
    
    func saveInBackgroundWithBlock(completion:((success: Bool, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().persistenceService.of(self.ofClass()).save(self, response: { (object) in
            
            if let responseObject = object as? FTDataObject {
                self.objectId = responseObject.objectId
            }
            
            completion?(success: true, error: nil)
            
        }) { (fault) in
            completion?(success: false, error: NSError.errorWithFault(fault))
        }
    }
    
    func saveInBackground(completion:((object: FTDataObject?, error: NSError?) -> ())?) {
        
        Backendless.sharedInstance().persistenceService.of(self.ofClass()).save(self, response: { (response) in
            
            if let responseObject = response as? FTDataObject {
                completion?(object: responseObject, error: nil)
            }
            else {
                completion?(object: nil, error: NSError(domain: "Backendless", code: -6668, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Return object missing type", comment: "Error when saving object")]))
            }
            
        }) { (fault) in
            completion?(object: nil, error: NSError.errorWithFault(fault))
        }
    }
    
    class func saveAllInBackground(objects: [FTDataObject], completion:((success: Bool, error: NSError?) -> ())?) {
        
        let group = dispatch_group_create();
        var successCount = 0
        let totalCount = objects.count
        
        for object in objects {
            
            dispatch_group_enter(group)
            
            object.deleteInBackgroundWithBlock({ (success, error) in
                if success {
                    successCount += 1
                }
                dispatch_group_leave(group)
            })
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            
            if successCount == totalCount {
                completion?(success: true, error: nil)
            }
            else {
                completion?(success: false, error: NSError(domain: "Backendless", code: -6668, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Some objects failed to delete", comment: "Error message when some objects failed to delete in a mass deletion")]))
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteInBackgroundWithBlock(completion:((success: Bool, error: NSError?) -> ())?) {
        
        if self.objectId == nil && self.objectId!.isEmpty {
            completion?(success: false, error: NSError(domain: "Backendless", code: -6667, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("No objectid", comment: "Error message when object missing id")]))
        }
        else {
            Backendless.sharedInstance().persistenceService.of(self.ofClass()).removeID(self.objectId!, response: { (response) in
                
                completion?(success: true, error: nil)
                
                }, error: { (fault) in
                    completion?(success: false, error: NSError.errorWithFault(fault))
            })
        }
    }
    
    class func dataStore() -> IDataStore {
        
        let dataStore = Backendless.sharedInstance().persistenceService.of(self.classForCoder())
        
        return dataStore
    }

}
