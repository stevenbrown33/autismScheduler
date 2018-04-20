//
//  ActivityController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

let activitiesWereSetNotification = Notification.Name("childrenWereSet")

protocol ActivityControllerDelegate: class {
    func activitiesUpdated()
}

class ActivityController {
    
    //MARK: - Properties
    static let shared = ActivityController()
    let database = CKContainer.default().privateCloudDatabase
    let ckManager = CloudKitManager.shared
    var activity: Activity?
    var activities: [Activity] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: activitiesWereSetNotification, object: nil)
            }
        }
    }
    var currentActivity: Activity?
    
    init() {
        fetchActivitiesFromCloudKit()
    }
    
    // MARK: - CRUD
    func addActivity(named name: String, withImage image: UIImage?) {
        guard let image = image else { return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let activity = Activity(name: name, imageData: data)
        activities.append(activity)
        let record = activity.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving activity to CloudKit: \(error.localizedDescription)")
            } else {
                activity.cloudKitRecordID = record?.recordID
            }
            self.saveActivitiesToCloudKit()
        }
    }
    
    func update(activity: Activity, name: String, image: UIImage?) {
        activity.name = name
        //activity.image = image
        saveActivitiesToCloudKit()
    }
    
    func deleteActivity(activity: Activity) {
        guard let activityRecordID = activity.cloudKitRecordID else { return }
        database.delete(withRecordID: activityRecordID) { (_, error) in
            if let error = error {
                print("Error deleting activity: \(error.localizedDescription)")
            } else {
                self.fetchActivitiesFromCloudKit()
                print("Activity deleted")
            }
        }
    }
    
    // MARK: - Persistence
    func saveActivitiesToCloudKit() {
        let records = activities.map({ $0.cloudKitRecord })
        ckManager.saveRecordsToCloudKit(records: records, database: database, perRecordCompletion: nil) { (records, _, error) in
            if let error = error {
                print("Error saving activity records to CloudKit: \(error.localizedDescription)")
            } else {
                print("Sucessfully saved activity records to CloudKit")
            }
        }
    }
    
    func fetchActivitiesFromCloudKit() {
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
            })
        }
    }
    
    func fetchTasksFor(activity: Activity, completion: @escaping () -> Void) {
        guard let activityRecordID = activity.cloudKitRecordID else { completion(); return }
        let activityReference = CKReference(recordID: activityRecordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "activityRef == %@", activityReference)
        ckManager.fetchRecordsOf(type: Task.typeKey, predicate: predicate, database: database) { (records, error) in
            if let error = error { print("Error fetching tasks from CloudKit: \(error.localizedDescription)")}
            guard let records = records else { completion(); return }
            let tasks = records.compactMap({ Task(cloudKitRecord: $0) })
            activity.tasks = tasks
            completion()
        }
    }
}
