//
//  CoreData.swift
//  DemoSwift
//
//  Created by mac-0007 on 03/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}




//======================================================

typealias BlockVoid                         = () -> Void
typealias BlockManagedObjectEnumeration     = (_ managedObject:NSManagedObject, _ object:NSDictionary, _ idx:UInt, _ stop:Bool) -> Void
typealias BlockManagedObjectResult          = (_ managedObject:NSManagedObject?, _ error:NSError?) -> Void
typealias BlockArrayResult                  = (_ objects:NSArray?, _ error:NSError?) -> Void
typealias BlockCountResult                  = (_ count:Int, _ error:NSError?) -> Void
typealias BlockChangesResult                = (_ result:NSArray, _ type:NSManagedObjectChangeType) -> Void

enum NSManagedObjectChangeType:Int
{
    case insert
    case update
    case delete
    case all
}

enum BlockType:String
{
    case observer   = "observer"
    case block      = "block"
}

class WrapperBlockVoid : NSObject
{
    var block : BlockVoid
    init(block: @escaping BlockVoid) {
        self.block = block
    }
}

class WrapperBlockChangesResult : NSObject
{
    var block : BlockChangesResult
    init(block: @escaping BlockChangesResult) {
        self.block = block
    }
}

//======================================================





class CoreData: NSObject
{
    var primaryKeys:NSMutableDictionary?
    var arrChangesObserver:NSMutableArray?
    
    //MARK:
    //MARK:- CoreData Variable
    
    lazy var modelName: String = {
        // Default: Model
        return "Model"
    }()
    
    lazy var sqliteDatabaseName: String = {
        // Default: Data.sqlite
        return "Data.sqlite"
    }()
    
    lazy var initializeDatabaseName: String = {
        // Not used as default
        return "Data"
    }()
    
    lazy var databaseFileDirectory: String = {
        // Default: NSHomeDirectory().stringByAppendingString("Documents")
        return NSHomeDirectory() + "/Library/Caches"
    }()
    
    lazy var coreDataURL: URL = {
        return URL(fileURLWithPath: self.databaseFileDirectory+"/"+self.sqliteDatabaseName)
    }()
    
    
    
    //MARK:
    //MARK:- iCloud Variable
    
    var iCloudEnabledAppID: String?
    
    lazy var iCloudDatabaseDirectory: String = {
        return "Data.nosync"
    }()
    
    lazy var iCloudLogsDirectory: String = {
        return "Logs"
    }()
    
    
    
    
    //MARK:
    //MARK:- Core Data stack
    
    lazy var managedObjectModel: NSManagedObjectModel! = {
        //        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        //        return NSManagedObjectModel(contentsOfURL: modelURL)!
        
        return NSManagedObjectModel.mergedModel(from: nil)
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        var dbURL = self.coreDataURL
        
        let options : NSMutableDictionary = NSMutableDictionary()
        options.setObject(FileProtectionType.none, forKey: FileAttributeKey.protectionKey as NSCopying)
        options.setObject(NSNumber(value: true as Bool), forKey: NSMigratePersistentStoresAutomaticallyOption as NSCopying)
        options.setObject(NSNumber(value: true as Bool), forKey: NSInferMappingModelAutomaticallyOption as NSCopying)
        
        if(!FileManager.default.fileExists(atPath: dbURL.path))
        {
            let preloadPath = Bundle.main.path(forResource: self.initializeDatabaseName, ofType: "sqlite")
            
            if((preloadPath != nil) && FileManager.default.fileExists(atPath: preloadPath!))
            {
                do {
                    try FileManager.default.copyItem(at: URL(fileURLWithPath: preloadPath!), to: dbURL)
                } catch {
                    print("Error: Couldn't copy preloaded data \(error)")
                }
            }
        }
        
        if((self.iCloudEnabledAppID) != nil)
        {
            let fileManager:FileManager = FileManager.default
            let iCloudRoot:URL? = fileManager.url(forUbiquityContainerIdentifier: nil)
            
            if(iCloudRoot != nil)
            {
                let strPath:String! = (iCloudRoot?.path)! + ("/"+self.iCloudLogsDirectory)
                let iCloudLogsPath:URL = URL(fileURLWithPath: strPath)
                
                if(!fileManager.fileExists(atPath: strPath))
                {
                    do {
                        try fileManager.createDirectory(atPath: strPath, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error: Creating Database Directory \(error)")
                    }
                }
                
                let iCloudData:String = strPath + ("/"+self.sqliteDatabaseName)
                options.setObject(self.iCloudEnabledAppID!, forKey: NSPersistentStoreUbiquitousContentNameKey as NSCopying)
                options.setObject(iCloudLogsPath, forKey: NSPersistentStoreUbiquitousContentURLKey as NSCopying)
                
                dbURL = URL(fileURLWithPath: iCloudData)
            }
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: options as? [AnyHashable: Any])
        } catch
        {
            // Report any error we got.
            var failureReason = "There was an error creating or loading the application's saved data."
            
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            #if DEBUG
                abort()
            #endif
        }
        
        return coordinator
    }()
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var privateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var childManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    lazy var newManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    
    
    //MARK:
    //MARK:- Singleton Object
    
    static let sharedInstance = CoreData.init()
    
    override init()
    {
        super.init()
        
        primaryKeys = NSMutableDictionary()
        arrChangesObserver = NSMutableArray()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil)
        { (notification) in
            
            let mObjectContext:NSManagedObjectContext = self.mainManagedObjectContext
            let nObjectContext:NSManagedObjectContext = notification.object as! NSManagedObjectContext
            
            if(mObjectContext != nObjectContext && nObjectContext.parent == nil &&
                mObjectContext.persistentStoreCoordinator == nObjectContext.persistentStoreCoordinator)
            {
                mObjectContext.performAndWait({
                    mObjectContext.mergeChanges(fromContextDidSave: notification)
                })
                
                self.observeChangesOnContextDidSave(notification: notification)
            }
            else if(mObjectContext == nObjectContext) {
                self.observeChangesOnContextDidSave(notification: notification)
            }
        }
    }
    
    
    //MARK:
    //MARK:- Instance Method
    
    fileprivate func observeChangesOnContextDidSave(notification:Notification) -> Void
    {
        if (arrChangesObserver != nil && arrChangesObserver?.count > 0)
        {
            self.performBlock(block: {
                let arrEntity:NSArray = NSSet.init(array: self.arrChangesObserver!.value(forKeyPath: "entity") as! [AnyObject]).allObjects as NSArray
                
                for entity in arrEntity
                {
                    
                    let oPredicate: NSPredicate = NSPredicate(format: "entity.name = %@",entity as! [AnyObject])
                    let arrUpdated: NSArray = (((notification.userInfo! as NSDictionary)["updated"]! as AnyObject).allObjects as NSArray).filtered(using: oPredicate) as NSArray
                    let arrInserted: NSArray = (((notification.userInfo! as NSDictionary)["inserted"]! as AnyObject).allObjects as NSArray).filtered(using: oPredicate) as NSArray
                    let arrDeleted: NSArray = (((notification.userInfo! as NSDictionary)["deleted"]! as AnyObject).allObjects as NSArray).filtered(using: oPredicate) as NSArray
                    
                    
                    if(arrUpdated.count > 0 || arrInserted.count > 0 || arrDeleted.count > 0)
                    {
                        let arrTemp = self.arrChangesObserver!.filtered(using: NSPredicate(format: "entity = %@", entity as! NSObject))
                        for dict in arrTemp
                        {
                            let block = (dict as! NSDictionary)["block"] as! BlockChangesResult?
                            let observer = (dict as! NSDictionary)["observer"] as! BlockVoid?
                            var iPredicate = (dict as! NSDictionary)["predicate"]  as! NSPredicate?
                            let cPredicate = (dict as! NSDictionary)["changes"]  as! NSPredicate?
                            let type = (dict as! NSDictionary)["type"] as! NSManagedObjectChangeType
                            
                            var arrChanged:NSArray?
                            
                            if (iPredicate == nil) {
                                iPredicate = NSPredicate(format: "1 == 1")
                            }
                            
                            switch (type)
                            {
                            case .insert:
                                arrChanged = arrInserted.filtered(using: iPredicate!) as NSArray
                                break
                            case .update:
                                arrChanged = arrUpdated.filtered(using: iPredicate!) as NSArray
                                break
                            case .delete:
                                arrChanged = arrDeleted.filtered(using: iPredicate!) as NSArray
                                break
                            case .all:
                                
                                let arrResults = NSMutableArray()
                                arrResults.addObjects(from: arrInserted.filtered(using: iPredicate!))
                                
                                if(observer != nil && arrResults.count > 0) {
                                    arrResults.addObjects(from: arrUpdated.filtered(using: iPredicate!))
                                }
                                
                                if(observer != nil && arrResults.count > 0) {
                                    arrResults.addObjects(from: arrDeleted.filtered(using: iPredicate!))
                                }
                                
                                arrChanged = arrResults
                                
                                break
                            }
                            
                            if(cPredicate != nil)
                            {
                                
                                arrChanged = arrChanged?.filtered(using: NSPredicate(format: "changedValues IN %@", (arrChanged?.value(forKeyPath: "changedValues") as! NSArray).filtered(using: cPredicate!))) as NSArray?
                            }
                            
                            if(arrChanged?.count > 0)
                            {
                                self.performBlockOnMainThread(block: {
                                    if (observer != nil) {
                                        observer!()
                                    }
                                    else if(block != nil)
                                    {
                                        let arrMainValues = NSMutableArray()
                                        
                                        for object in arrChanged!
                                        {
                                            arrMainValues.add(CoreData.sharedInstance.mainManagedObjectContext.object(with: (object as! NSManagedObject).objectID))
                                        }
                                        
                                        block!(arrMainValues, type)
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    class func saveContext() -> Void
    {
        CoreData.sharedInstance.saveContext()
    }
    
    func saveContext() -> Void
    {
        self.mainManagedObjectContext.saveContext()
    }
    
    func truncate() -> Void
    {
        let context:NSManagedObjectContext = self.newManagedObjectContext
        
        for entity:NSEntityDescription in self.managedObjectModel.entities
        {
            let aClass = NSClassFromString(entity.managedObjectClassName) as! NSManagedObject.Type
            aClass.deleteAllObjects(context: context, block: nil)
        }
        context.saveContext()
    }
}
