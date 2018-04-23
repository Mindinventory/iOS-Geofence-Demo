//
//  CoreDataObject+Extension.swift
//  DemoSwift
//
//  Created by mac-0007 on 05/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject
{
    class  func findEntity() -> String
    {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    class func entityDescription() -> NSEntityDescription
    {
        return NSEntityDescription.entity(forEntityName: self.findEntity(), in: CoreData.sharedInstance.mainManagedObjectContext)!
    }
    
    class func entityContext() -> NSManagedObjectContext
    {
        if ((CoreData.sharedInstance.primaryKeys?.object(forKey: self.findEntity())) != nil)
        {
            return (CoreData.sharedInstance.primaryKeys?.object(forKey: self.findEntity()))! as! NSManagedObjectContext
        } else
        {
            let context:NSManagedObjectContext = CoreData.sharedInstance.childManagedObjectContext
            if #available(iOS 10.0, *) {
                CoreData.sharedInstance.primaryKeys?.setObject(context, forKey: self.entity())
            } else {
                // Fallback on earlier versions
            }
            return context
        }
    }
    
    class func convert(object:NSManagedObject) -> NSManagedObject
    {
        if (object.managedObjectContext == self.entityContext()) {
            return object
        }
        
        if (object.objectID.isTemporaryID)
        {
            do {
                try object.managedObjectContext?.obtainPermanentIDs(for: [object])
            } catch {}
            
            return self.entityContext().object(with: object.objectID)
        } else
        {
            return self.entityContext().object(with: object.objectID)
        }
    }
    
    
    
    class func performSafeBlock(block: @escaping BlockVoid) -> Void
    {
        self.entityContext().performSafeBlock {
            block()
        }
    }
    
    class func performBlockAndWait(block:@escaping BlockVoid) -> Void
    {
        self.entityContext().performAndWait {
            block()
        }
    }
    
    
    
    func entityContext() -> NSManagedObjectContext
    {
        return NSManagedObject.entityContext()
    }
    
    func editableObejct() -> NSManagedObject
    {
        if (self.managedObjectContext == self.entityContext()) {
            return self
        } else {
            return NSManagedObject.convert(object: self)
        }
    }
    
    
    
    class func convert(value:AnyObject, forAttribute attribute:String) -> AnyObject?
    {
        var value = value
        let attributeType:NSAttributeType = (self.entityDescription().attributesByName as NSDictionary).object(forKey: attribute)!.attributeType
        
        if (attributeType == .stringAttributeType && (value is NSNumber)) {
            value = value.stringValue as AnyObject
        }
        else if((attributeType == .integer16AttributeType || attributeType == .integer32AttributeType || attributeType == .integer64AttributeType || attributeType == .booleanAttributeType) && (value is String))
        {
            value = NSNumber(value: value.intValue as Int)
        }
        else if((attributeType == .floatAttributeType || attributeType == .decimalAttributeType || attributeType == .doubleAttributeType) && (value is String))
        {
            value = NSNumber(value: value.doubleValue as Double)
        }
        
        return value
    }
    
    func set(value:AnyObject?, forAttribute attribute:String) -> Void
    {
        
        if (value == nil) {
            return
        }
        
        self.setValue(NSManagedObject.convert(value: value!, forAttribute: attribute), forKey: attribute)
    }
    
    func setKeyValue(dictionary dict:NSDictionary?) -> Void
    {
        let attributes:NSDictionary = self.entity.attributesByName as NSDictionary
        for (key, _) in attributes {
            self.setValue(dict?.value(forKey: key as! String), forKey: key as! String)
        }
    }
    
    
    
    
    
    
    //MARK:
    //MARK:- Create NSManagedObject
    
    class func create(dictionary dict:NSDictionary?) -> NSManagedObject
    {
        return self.createManagedObject(dictionary: dict, context: nil)
    }
    
    class func create(dictionary dict:NSDictionary?, block:BlockManagedObjectResult?) -> Void
    {
        self.createManagedObject(dictionary: dict, context: nil, block: block)
    }
    
    class func create(dictionary dict:NSDictionary?, context:NSManagedObjectContext?) -> NSManagedObject
    {
        return self.createManagedObject(dictionary: dict, context: context)
    }
    
    class func create(dictionary dict:NSDictionary?, context:NSManagedObjectContext?, block:BlockManagedObjectResult?) -> Void
    {
        self.createManagedObject(dictionary: dict, context: context, block: block)
    }
    
    class func update(dictionary dict:NSDictionary?, predicate:NSPredicate?, context:NSManagedObjectContext?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            
            if(NSClassFromString("NSBatchUpdateRequest") != nil)
            {
                let batchUpdateRequest = NSBatchUpdateRequest(entityName: self.findEntity())
                batchUpdateRequest.resultType = .updatedObjectIDsResultType
                batchUpdateRequest.propertiesToUpdate = dict as? [AnyHashable: Any]
                
                if (predicate != nil) {
                    batchUpdateRequest.predicate = predicate
                }
                
                do
                {
                    let batchUpdateResult = try context?.execute(batchUpdateRequest) as? NSBatchUpdateResult
                    let objectIDs = batchUpdateResult!.result
                    
                    for objectID in objectIDs as! NSArray
                    {
                        let managedObject = context?.object(with: objectID as! NSManagedObjectID)
                        if (managedObject != nil) {
                            context?.refresh(managedObject!, mergeChanges: false)
                        }
                    }
                }
                catch
                {
                    print("Execute NSBatchUpdateRequest \(error)")
                }
            }
            else
            {
                let result = self.fetch(predicate: predicate, sortDescriptors: nil, context: context)
                for (key, value) in dict! {
                    result?.setValue(value, forKeyPath: key as! String)
                }
                
                context?.saveContext()
            }
        })
    }
    
    fileprivate class func createManagedObject(dictionary dict:NSDictionary?, context:NSManagedObjectContext?) -> NSManagedObject
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: self.findEntity(), into: context!)
        managedObject.setKeyValue(dictionary: dict)
        
        return managedObject
    }
    
    fileprivate class func createManagedObject(dictionary dict:NSDictionary?, context:NSManagedObjectContext?, block:BlockManagedObjectResult?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            
            let object = self.createManagedObject(dictionary: dict, context: context)
            if (block != nil) {
                block!(object, nil)
            }
        })
    }
    
    
    
    
    //MARK:
    //MARK:- FindOrCreate NSManagedObject
    
    class func findOrCreate(dictionary dict:NSDictionary?) -> NSManagedObject
    {
        return self.findOrCreate(dictionary: dict, context: nil)
    }
    
    class func findOrCreate(dictionary dict:NSDictionary?, block:@escaping BlockManagedObjectResult) -> Void
    {
        self.findOrCreate(dictionary: dict, context: nil, block: block)
    }
    
    class func findOrCreate(dictionary dict:NSDictionary?, context:NSManagedObjectContext?) -> NSManagedObject
    {
        var predicates = [NSPredicate]()
        print(predicates)
        if (dict != nil)
        {
            for (key, value) in dict! {
                predicates.append(NSPredicate(format: "%K == %@", key as! NSObject, value as! NSObject))
            }
        }
        
        return self.findOrCreateManagedObject(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), dict: dict, context: context)
    }
    
    class func findOrCreate(dictionary dict:NSDictionary?, context:NSManagedObjectContext?, block:@escaping BlockManagedObjectResult) -> Void
    {
        var predicates = [NSPredicate]()
        
        if (dict != nil)
        {
            for (key, value) in dict! {
                predicates.append(NSPredicate(format: "%K == %@", key as! NSObject, value as! NSObject))
            }
        }
        
        self.findOrCreateManagedObject(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), dict: dict, context: context, block: block)
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?) -> NSManagedObject
    {
        return self.findOrCreateManagedObject(predicate: predicate, dict: nil, context: nil)
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?, block:BlockManagedObjectResult?) -> Void
    {
        self.findOrCreateManagedObject(predicate: predicate, dict: nil, context: nil, block: block)
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?, dict:NSDictionary) -> NSManagedObject
    {
        return self.findOrCreateManagedObject(predicate: predicate, dict: dict, context: nil)
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?, dict:NSDictionary, block:BlockManagedObjectResult?) -> Void
    {
        self.findOrCreateManagedObject(predicate: predicate, dict: dict, context: nil, block: block)
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?, dict:NSDictionary?, context:NSManagedObjectContext?, block:BlockManagedObjectResult?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            let object = self.findOrCreateManagedObject(predicate: predicate, dict: dict, context: context)
            if (block != nil) {
                block!(object, nil)
            }
        })
    }
    
    fileprivate class func findOrCreateManagedObject(predicate:NSPredicate?, dict:NSDictionary?, context:NSManagedObjectContext?) -> NSManagedObject
    {
        var managedObject:NSManagedObject?
        
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        if (predicate != nil)
        {
            let fetchRequest = self.fetchRequest(predicate: predicate, sortDescriptors: nil, fetchLimit: 1)
            
            do
            {
                let result = try context!.fetch(fetchRequest)
                managedObject = result.last as? NSManagedObject
            }
            catch
            {
                print("Execute fetchRequest \(error)")
            }
        }
        
        if (managedObject == nil) {
            managedObject = self.create(dictionary: dict, context: context)
        }
        
        return managedObject!
    }
    
    
    
    
    
    //MARK:
    //MARK:- Fetch Count
    
    class func count(predicate:NSPredicate?) -> Int
    {
        return self.count(predicate: predicate, context: nil)
    }
    
    class func count(predicate:NSPredicate?, block:BlockCountResult?) -> Void
    {
        self.count(predicate: predicate, context: nil, block: block)
    }
    
    class func count(predicate:NSPredicate?, context:NSManagedObjectContext?) -> Int
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        let fetchRequest:NSFetchRequest = self.fetchRequest(predicate: predicate, sortDescriptors: nil, fetchLimit: 0)
        fetchRequest.includesPropertyValues = false
        let count = try! context?.count(for: fetchRequest)
        
        return count!
    }
    
    class func count(predicate:NSPredicate?, context:NSManagedObjectContext?, block:BlockCountResult?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            let count:Int = self.count(predicate: predicate, context: nil)
            
            if (block != nil) {
                block!(count, nil)
            }
        })
    }
    
    
    
    
    //MARK:
    //MARK:- Fetch Objects
    
    class func fetchAllObjects() -> NSArray?
    {
        return self.fetch(predicate: nil, sortDescriptors: nil)
    }
    
    class func fetchAllObjects(block:BlockArrayResult?) -> Void
    {
        self.fetch(predicate: nil, sortDescriptors: nil, block: block)
    }
    
    class func fetch(predicate:NSPredicate?) -> NSArray?
    {
        return self.fetch(predicate: predicate, sortDescriptors: nil)
    }
    
    class func fetch(predicate:NSPredicate?, block:BlockArrayResult?) -> Void
    {
        self.fetch(predicate: predicate, sortDescriptors: nil, block: block)
    }
    
    class func fetch(predicate:NSPredicate?, orderBy:String?, ascending:Bool) -> NSArray?
    {
        var sortDescriptors:[NSSortDescriptor]?
        
        if (orderBy != nil && (orderBy?.blank())!) {
            sortDescriptors = [NSSortDescriptor(key: orderBy, ascending: ascending)]
        }
        
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: 0)
    }
    
    class func fetch(predicate:NSPredicate?, orderBy:String?, ascending:Bool, block:BlockArrayResult?) -> Void
    {
        var sortDescriptors:[NSSortDescriptor]?
        
        if (orderBy != nil && (orderBy?.blank())!) {
            sortDescriptors = [NSSortDescriptor(key: orderBy, ascending: ascending)]
        }
        
        self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: 0, block: block)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?) -> NSArray?
    {
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: 0)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, block:BlockArrayResult?) -> Void
    {
        self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: 0, block: block)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, fetchLimit:Int) -> NSArray?
    {
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: fetchLimit)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, fetchLimit:Int, block:BlockArrayResult?) -> Void
    {
        self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: nil, fetchLimit: fetchLimit, block: block)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, context:NSManagedObjectContext?) -> NSArray?
    {
        return self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context, fetchLimit: 0)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, context:NSManagedObjectContext?, block:BlockArrayResult?) -> Void
    {
        self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context, fetchLimit: 0, block: block)
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, context:NSManagedObjectContext?, fetchLimit:Int) -> NSArray?
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        var result = NSArray()
        let fetchRequest = self.fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
        
        do {
            result = try context!.fetch(fetchRequest) as NSArray
        } catch {
            print("Execute fetchRequest \(error)")
        }
        
        return result
    }
    
    class func fetch(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, context:NSManagedObjectContext?, fetchLimit:Int, block:BlockArrayResult?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            
            let result = self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context, fetchLimit: fetchLimit)
            
            if (block != nil) {
                block!(result, nil)
            }
        })
    }
    
    class func fetchRequest(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, fetchLimit:Int) -> NSFetchRequest<NSFetchRequestResult>
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: self.findEntity())
        
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        
        if (sortDescriptors != nil) {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        fetchRequest.fetchLimit = fetchLimit
        
        return fetchRequest
    }
    
    class func fetchAsynchronously(predicate:NSPredicate?, sortDescriptors:[NSSortDescriptor]?, context:NSManagedObjectContext?, fetchLimit:Int, block:BlockArrayResult?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        if (NSClassFromString("NSAsynchronousFetchRequest") != nil)
        {
            let fetchRequest = self.fetchRequest(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest, completionBlock: { (result) in
                
                if (block != nil) {
                    block!(result.finalResult as NSArray?, nil)
                }
            })
            
            context?.performSafeBlock(block: {
                do
                {
                    let asynchronousFetchResult = try context?.execute(asynchronousFetchRequest)
                    print("NSAsynchronousFetchResult result: \(String(describing: asynchronousFetchResult))")
                }
                catch
                {
                    print("NSAsynchronousFetchResult error: \(error)")
                }
            })
        }
        else
        {
            assert(context?.concurrencyType != .privateQueueConcurrencyType, "Use context with concurrencyType PrivateQueueConcurrencyType, otherwise it will not fetch data Asynchronously.")
            
            context?.performSafeBlock(block: {
                let result = self.fetch(predicate: predicate, sortDescriptors: sortDescriptors, context: context, fetchLimit: fetchLimit)
                
                if (block != nil) {
                    block!(result, nil)
                }
            })
        }
    }
    
    
    
    
    
    
    //MARK:
    //MARK:- Delete Objects
    
    class func deleteAllObjects() -> Void
    {
        self.deleteAllObjects(context: nil)
    }
    
    class func deleteAllObjects(context:NSManagedObjectContext?) -> Void
    {
        self.deleteObjects(predicate: nil, context: context)
    }
    
    class func deleteAllObjects(context:NSManagedObjectContext?, block:BlockVoid?) -> Void
    {
        self.deleteObjects(predicate: nil, context: context, block: block)
    }
    
    class func deleteObjects(predicate:NSPredicate?) -> Void
    {
        self.deleteObjects(predicate: predicate, context: CoreData.sharedInstance.mainManagedObjectContext)
    }
    
    class func deleteObjects(predicate:NSPredicate?, block:BlockVoid?) -> Void
    {
        self.deleteObjects(predicate: predicate, context: CoreData.sharedInstance.mainManagedObjectContext, block: block)
    }
    
    class func deleteObjects(predicate:NSPredicate?, context:NSManagedObjectContext?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        let fetchRequest:NSFetchRequest = self.fetchRequest(predicate: predicate, sortDescriptors: nil, fetchLimit: 0)
        
        if (NSClassFromString("NSBatchDeleteRequest") != nil)
        {
            // iOS 9 and later
            if #available(iOS 9.0, *) {
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context?.execute(deleteRequest)
                    context?.saveContext()
                } catch {
                    print("Execute NSBatchDeleteRequest \(error)")
                }
            }
        }
        else
        {
            fetchRequest.includesPropertyValues = false
            
            do
            {
                let result = try context!.fetch(fetchRequest)
                
                for managedObject in result {
                    context?.delete(managedObject as! NSManagedObject)
                }
                
                context?.saveContext()
            }
            catch
            {
                print("Execute NSFetchRequest \(error)")
            }
        }
    }
    
    class func deleteObjects(predicate:NSPredicate?, context:NSManagedObjectContext?, block:BlockVoid?) -> Void
    {
        var context = context
        if (context == nil) {
            context = CoreData.sharedInstance.mainManagedObjectContext
        }
        
        context?.performSafeBlock(block: {
            self.deleteObjects(predicate: predicate, context: nil)
            if(block != nil) {
                block!()
            }
        })
    }
    
    func deleteObject() -> Void
    {
        self.managedObjectContext?.delete(self)
        self.managedObjectContext?.saveContext()
    }
    
    func deleteObject(block:BlockVoid?) -> Void
    {
        self.managedObjectContext?.performSafeBlock(block: {
            self.deleteObject()
            
            if(block != nil) {
                block!()
            }
        })
    }
    
    
    
    
    //MARK:
    //MARK:- Observer NSManagedObject
    
    
    func observeChanges(block:BlockVoid?) -> Void
    {
        assert((self.managedObjectContext?.isEqual(CoreData.sharedInstance.mainManagedObjectContext))!, "You should observer changes on mainManagedObjectContext Only.")
        
        if (self.objectID.isTemporaryID) {
            self.managedObjectContext?.saveContext()
        }
        
        NSManagedObject.changedObjects(changeType: .update, predicate: NSPredicate(format: "objectID = %@", self.objectID)) {
            if(block != nil) {
                block!()
            }
        }
    }
    
    class func changedObjects(block:BlockChangesResult?) -> Void
    {
        self.changedObjects(changeType:.all, predicate: nil, block: block)
    }
    
    class func changedObjects(block:BlockVoid?) -> Void
    {
        self.changedObjects(changeType:.all, predicate: nil, block: block!)
    }
    
    class func changedObjects(predicate:NSPredicate?, block:BlockChangesResult?) -> Void
    {
        self.changedObjects(changeType:.all, predicate: predicate, block: block)
    }
    
    class func changedObjects(predicate:NSPredicate?, block:BlockVoid?) -> Void
    {
        self.changedObjects(changeType:.all, predicate: predicate, block: block!)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, block:BlockChangesResult?) -> Void
    {
        self.changedObjects(changeType: type, predicate: nil, block: block)
    }
    
    
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, block:BlockVoid?) -> Void
    {
        self.changedObjects(changeType: type, predicate: nil, block: block!)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, predicate:NSPredicate?, block:BlockChangesResult?) -> Void
    {
        self.changedObjects(changeType: type, predicate: predicate, block: WrapperBlockChangesResult.init(block: block!), blockType: BlockType.block, changePredicate: nil)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, predicate:NSPredicate?, block:BlockVoid?) -> Void
    {
        self.changedObjects(changeType: type, predicate: predicate, block: WrapperBlockVoid.init(block: block!), blockType: BlockType.observer, changePredicate: nil)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, predicate:NSPredicate?, changePredicate:NSPredicate?, block:BlockVoid?) -> Void
    {
        self.changedObjects(changeType: type, predicate: predicate, block: WrapperBlockVoid.init(block: block!), blockType: BlockType.observer, changePredicate: changePredicate)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, predicate:NSPredicate?, properties:NSArray?, block:@escaping BlockChangesResult) -> Void
    {
        var changePredicate:NSPredicate?
        
        for property in properties!
        {
            let tempPredicate = NSPredicate(format: "%K != nil", property as! [AnyObject])
            
            if (changePredicate == nil) {
                changePredicate = tempPredicate
            } else {
                changePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [changePredicate!, tempPredicate])
            }
        }
        
        self.changedObjects(changeType: type, predicate: predicate, block: WrapperBlockChangesResult.init(block: block), blockType: BlockType.block, changePredicate: nil)
    }
    
    class func changedObjects(changeType type:NSManagedObjectChangeType, predicate:NSPredicate?, block:AnyObject, blockType:BlockType, changePredicate:NSPredicate?) -> Void
    {
        let dict = NSMutableDictionary()
        dict.setValue(self.findEntity(), forKey: "entity")
        dict.setValue(NSNumber(value: type.rawValue as Int), forKey: "type")
        dict.setValue(block, forKey: blockType.rawValue)
        
        if (predicate != nil) {
            dict.setValue(predicate, forKey: "predicate")
        }
        
        if (changePredicate != nil) {
            dict.setValue(changePredicate, forKey: "changes")
        }
        
        if (CoreData.sharedInstance.arrChangesObserver?.contains(dict) == false) {
            CoreData.sharedInstance.arrChangesObserver?.add(dict)
        }
    }
    
    class func deleteObservers() -> Void
    {
        
        let array = CoreData.sharedInstance.arrChangesObserver?.filtered(using: (NSPredicate(format: "entity == %@", self.findEntity())))
        
        CoreData.sharedInstance.arrChangesObserver?.removeObjects(in: array!)
    }
    
    class func deleteObserver(block:BlockVoid?) -> Void
    {
        
        let array = CoreData.sharedInstance.arrChangesObserver?.filtered(using: (NSPredicate(format: "entity == %@ && observer == %@", self.findEntity(), WrapperBlockVoid.init(block: block!))))
        
        CoreData.sharedInstance.arrChangesObserver?.removeObjects(in: array!)
    }
    
    class func deleteObserver(block:BlockChangesResult?) -> Void
    {
        
        let array = CoreData.sharedInstance.arrChangesObserver?.filtered(using: (NSPredicate(format: "entity == %@ && block == %@", self.findEntity(), WrapperBlockChangesResult.init(block: block!))))
        
        CoreData.sharedInstance.arrChangesObserver?.removeObjects(in: array!)
    }
}
