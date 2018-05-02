//
//  ActivityController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

let activitiesWereSetNotification = Notification.Name("activitiesWereSet")

protocol ActivityControllerDelegate: class {
    func activitiesUpdated()
}

class ActivityController {
    
    //MARK: - Properties
    static let shared = ActivityController()
    let database = CKContainer.default().privateCloudDatabase
    let ckManager = CloudKitManager.shared
    var activities: [Activity] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: activitiesWereSetNotification, object: nil)
            }
        }
    }
    
    init() {
        fetchAllActivitiesFromCloudKit {
        }
    }
    
    // MARK: - CRUD
    func addActivity(named name: String, withImage image: UIImage?, isChecked: Bool = false, completion: @escaping () -> Void) {
        guard let image = image else { completion(); return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { completion(); return }
        let activity = Activity(name: name, imageData: data)
        activities.append(activity)
        let record = activity.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving activity to CloudKit: \(error.localizedDescription)")
                completion()
                return
            } else {
                activity.cloudKitRecordID = record?.recordID
            }
            
            self.saveActivityToCloudKit(activity: activity) {
                completion()
            }
        }
    }
    
    func update(activity: Activity, name: String, image: UIImage?, isChecked: Bool) {
        activity.name = name
        //activity.image = image
        activity.isChecked = isChecked
        saveActivityToCloudKit(activity: activity) {
        }
    }
    
    func deleteActivity(activity: Activity) {
        guard let activityRecordID = activity.cloudKitRecordID else { return }
        database.delete(withRecordID: activityRecordID) { (_, error) in
            if let error = error {
                print("Error deleting activity: \(error.localizedDescription)")
            } else {
                self.fetchAllActivitiesFromCloudKit {
                    print("Activities fetched after deleting")
                }
            }
        }
    }
    
    func updateChildCheckedActivities(child: Child, activities: [Activity], completion: () -> Void) {
        for activity in activities {
            let activityReference = CKReference(record: activity.cloudKitRecord, action: .none)
            if child.checkedActivities.contains(activityReference) {
                activity.isChecked = true
            } else {
                activity.isChecked = false
            }
        }
        completion()
    }
    
    func toggleIsCheckedFor(activity: Activity, child: Child) {
        activity.isChecked = !activity.isChecked
        let activityReference = CKReference(record: activity.cloudKitRecord, action: .none)
        if activity.isChecked == true {
            child.checkedActivities.append(activityReference)
        } else {
            if child.checkedActivities.contains(activityReference) {
                guard let index = child.checkedActivities.index(of: activityReference) else { return }
                child.checkedActivities.remove(at: index)
            }
        }
        ChildController.shared.saveChildToCloudKit(child: child) {
        }
    }
    
    // MARK: - Persistence
    func saveActivityToCloudKit(activity: Activity, completion: @escaping () -> Void) {
        let record = activity.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving activity to CloudKit. \(error.localizedDescription)")
            }
        }
        completion()
    }
    
    func fetchAllActivitiesFromCloudKit(completion: @escaping () -> Void) {
        let type = Activity.typeKey
        ckManager.fetchRecordsOf(type: type, database: database) { (records, error) in
            if let error = error {
                print("Error fetching activities from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { return }
            let activities = records.compactMap({ Activity(cloudKitRecord: $0 )})
            let group = DispatchGroup()
            for activity in activities {
                group.enter()
                self.fetchTasksFor(activity: activity, completion: {
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main, execute: {
                self.activities = activities
                completion()
            })
        }
    }
    
    func fetchTasksFor(activity: Activity, completion: @escaping () -> Void) {
        guard let activityRecordID = activity.cloudKitRecordID else { completion(); return }
        let activityReference = CKReference(recordID: activityRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "activityRef == %@", activityReference)
        ckManager.fetchRecordsOf(type: Task.typeKey, predicate: predicate, database: database) { (records, error) in
            if let error = error {
                print("Error fetching tasks from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { completion(); return }
            let tasks = records.compactMap({ Task(cloudKitRecord: $0, activity: activity) })
            activity.tasks = tasks
            completion()
        }
    }
}
