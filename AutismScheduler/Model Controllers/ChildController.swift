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
    
    //MARK: - Properties
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
        fetchChildrenFromCloudKit {
        }
    }
    
    // MARK: - CRUD
    func addChild(withName name: String, withImage image: UIImage?) {
        guard let image = image else { return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let child = Child(name: name, imageData: data)
        children.insert(child, at: 0)
        let record = child.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving child to CloudKit: \(error.localizedDescription)")
            } else {
                child.cloudKitRecordID = record?.recordID
            }
            self.saveChildToCloudKit(child: child, completion: {
            })
        }
    }
    
    func update(child: Child, name: String, image: UIImage?) {
        child.name = name
        guard let image = image else { return }
        child.imageData = UIImagePNGRepresentation(image)
        saveChildToCloudKit(child: child) {
        }
    }
    
    func deleteChild(child: Child) {
        guard let childRecordID = child.cloudKitRecordID else { return }
        database.delete(withRecordID: childRecordID) { (_, error) in
            if let error = error {
                print("Error deleting child: \(error.localizedDescription)")
            } else {
                // TODO: - This should remove the child from the array of children instead of fetching them again.
                self.fetchChildrenFromCloudKit {
                    print("Children fetched after deleting")
                }
                print("Child deleted")
            }
        }
    }
    
    // MARK: - Persistence
    func saveChildToCloudKit(child: Child, completion: @escaping () -> Void) {
        let record = child.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving child to CloudKit. \(error.localizedDescription)")
            }
        }
        completion()
    }

    func fetchChildrenFromCloudKit(completion:  @escaping () -> Void) {
        let type = Child.typeKey
        ckManager.fetchRecordsOf(type: type, database: database) { (records, error) in
            if let error = error {
                print("Error fetching contacts from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { return }
            let children = records.compactMap({ Child(cloudKitRecord: $0) })
            for child in children {
                child.activities = ActivityController.shared.activities
            }
                self.children = children
                completion()
        }
    }
}
