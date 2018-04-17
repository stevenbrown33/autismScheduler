//
//  ChildController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CoreData

protocol ChildControllerDelegate: class {
    func childrenUpdated()
}

class ChildController {
    
    var children: [Child] {
        return load()
    }
    weak var delegate: ChildControllerDelegate?
    static let shared = ChildController()
    private let context = CoreDataStack.context
//    var currentChild: Child?
    
    private init() {
        CloudKitManager.shared.fetchChanges { (success) in
            if !success { NSLog("Failed to update from stored record")}
        }
    }
    
    // MARK: - CRUD
    func addChild(withName name: String) -> Child {
        let child = Child(name: name)
        save()
        return child
    }
    
    func getChild(withRecordName recordName: String) -> Child? {
        return children.first(where: {$0.recordName == recordName})
    }
    
    func updateChild(_ child: Child, withName name: String) {
        child.name = name
        child.lastModificationTimestamp = Date().timeIntervalSince1970
        child.recordModified = true
        save()
    }
    
    func updateChildImage(for child: Child, toImage image: UIImage) {
        child.imageData = UIImageJPEGRepresentation(image, 1)
        child.lastModificationTimestamp = Date().timeIntervalSince1970
        child.recordModified = true
        save()
    }
    
    func removeChild(_ child: Child) {
        context.delete(child)
        CloudKitManager.shared.delete(entity: child) { (success) in
            if !success {
                NSLog("Warning: Failed to delete child")
            }
        }
    }
    
    // MARK: - Persistence
    private func save() {
        try? CoreDataStack.context.save()
        DispatchQueue.main.async {[weak self] in
            self?.delegate?.childrenUpdated()
        }
        for child in children.filter({$0.recordModified}) {
            updateChildBackup(child: child)
        }
    }
    
    private func updateChildBackup(child: Child) {
        var childSaved = true
        guard child.recordModified else { return }
        CloudKitManager.shared.updateEntity(entities: [child]) { (success) in
            if !success {
                NSLog("Failed to save child")
                childSaved = false
            }
             child.recordModified = !(childSaved)
        }
    }
    
    private func load() -> [Child] {
        let fetchRequest: NSFetchRequest<Child> = Child.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let results = try CoreDataStack.context.fetch(fetchRequest)
            return results
        } catch let error {
            NSLog("Error fetching children from file: \(error.localizedDescription)")
            return []
        }
    }
    
    func loadCloudBackup() {
        CloudKitManager.shared.loadEntities(ofType: Child.self, exclude: []) {[weak self] (retreivedObjects, error) in
            if let error = error {
                NSLog("Error fetching children from backup: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self?.delegate?.childrenUpdated()
            }
        }
    }
}
