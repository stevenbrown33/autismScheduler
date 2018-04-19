//
//  ChildController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

let childrenWereSetNotification = Notification.Name("childrenWereSet")

protocol ChildControllerDelegate: class {
    func childrenUpdated()
}

class ChildController {
    
    static let shared = ChildController()
    let database = CKContainer.default().privateCloudDatabase
    let ckManager = CloudKitManager.shared
    var children: [Child] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: childrenWereSetNotification, object: nil)
            }
        }
    }
    var currentChild: Child?
    
    init() {
        fetchChildrenFromCloudKit()
    }
    
    // MARK: - CRUD
    func addChild(withName name: String, withImage image: UIImage?) {
        guard let image = image else { return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let child = Child(name: name, imageData: data)
        children.insert(child, at: 0)
        ckManager.saveRecordToCloudKit(record: child.cloudKitRecord, database: database) { (record, error) in
            if let error = error {
                print("Error saving child to CloudKit: \(error.localizedDescription)")
            } else {
                child.cloudKitRecordID = record?.recordID
            }
            self.saveChildrenToCloudKit()
        }
    }
    
    func update(child: Child, name: String, image: UIImage?) {
        child.name = name
        //child.image = image
        saveChildrenToCloudKit()
//        ckManager.saveRecordToCloudKit(record: child.cloudKitRecord, database: database) { (record, error) in
//            if let error = error {
//                print("Error updating child in CloudKit: \(error.localizedDescription)")
//            } else {
//                child.cloudKitRecordID = record?.recordID
//                child.name = name
//                child.image = image
//            }
//        }
    }
    
    func deleteChild(child: Child) {
        guard let childRecordID = child.cloudKitRecordID else { return }
        database.delete(withRecordID: childRecordID) { (_, error) in
            if let error = error {
                print("Error deleting child: \(error.localizedDescription)")
            } else {
                self.fetchChildrenFromCloudKit()
                print("Child deleted")
            }
        }
    }
    
    // MARK: - Persistence
    
    func saveChildrenToCloudKit() {
        let records = children.map({ $0.cloudKitRecord })
        ckManager.saveRecordsToCloudKit(records: records, database: database, perRecordCompletion: nil) { (records, _, error) in
            if let error = error {
                print("Error saving child records to CloudKit: \(error.localizedDescription)")
            } else {
                print("Successfully saved child records to CloudKit")
            }
        }
    }
    
    private func fetchChildrenFromCloudKit() {
        ckManager.fetchRecordsOf(type: Child.typeKey, database: database) { (records, error) in
            if let error = error {
                print("Error fetching contacts from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { return }
            let children = records.compactMap({ Child(cloudKitRecord: $0) })
//            let group = DispatchGroup()
//            for child in children {
//                group.enter()
//                self.fetchActivitiesFor(child: child, completion: {
//                    group.leave()
//                })
//            }
//            group.notify(queue: DispatchQueue.main, execute: {
                self.children = children
//            })
        }
    }
    
//    func fetchActivitiesFor(child: Child, completion: @escaping () -> Void) {
//        guard let childRecordID = child.cloudKitRecordID else { completion(); return }
//        let childReference = CKReference(recordID: childRecordID, action: .deleteSelf)
//        let predicate = NSPredicate(format: "childRef == %@", childReference)
//        ckManager.fetchRecordsOf(type: Activity.typeKey, predicate: predicate, database: database) { (records, error) in
//            if let error = error { print("Error fetching activites from CloudKit: \(error.localizedDescription)")}
//            guard let records = records else { completion(); return }
//            let activities = records.compactMap({ Activity(cloudKitRecord: $0) })
//            child.activites = activities
//            completion()
//        }
//    }
}
