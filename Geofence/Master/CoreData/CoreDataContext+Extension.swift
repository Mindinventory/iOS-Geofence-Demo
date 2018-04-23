//
//  CoreDataContext+Extension.swift
//  DemoSwift
//
//  Created by mac-0007 on 05/09/16.
//  Copyright © 2016 Jignesh-0007. All rights reserved.
//

import Foundation
import CoreData


var kThread: UInt8 = 0
extension NSManagedObjectContext
{
    func saveContext() ->  Void
    {
        if (self.hasChanges)
        {
            self.performSafeBlock(block: {
                do {
                    try self.save()
                } catch {
                    print("Unresolved error \(error)")
                    if(self.parent != nil) {
                        self.parent?.saveContext()
                    }
                }
            })
        }
    }
    
    func performSafeBlock(block:@escaping BlockVoid) -> Void
    {
        let thread:Thread? = self.object(forKey: &kThread) as? Thread
        
        if ((self.concurrencyType == .mainQueueConcurrencyType && Thread.isMainThread) || thread == Thread.current) {
            block()
        }
        else
        {
            self.perform({
                if(thread == nil) {
                    self.set(object: Thread.current, forKey: &kThread)
                }
                block()
            })
        }
    }
}
