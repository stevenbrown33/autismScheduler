//
//  CoreDataStack.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStack {
    
    static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AutismScheduler")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error): \(error.userInfo)")
            }
        })
        return container
    }()
    static var context: NSManagedObjectContext {
        return container.viewContext
    }
}
