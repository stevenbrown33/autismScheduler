//
//  TaskController.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

let tasksWereSetNotification = Notification.Name("tasksWereSet")

protocol TaskControllerDelegate: class {
    func tasksUpdated()
}

class TaskController {
    
    //MARK: - Properties
    static let shared = TaskController()
    let database = CKContainer.default().privateCloudDatabase
    let ckManager = CloudKitManager.shared
    var tasks: [Task] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: tasksWereSetNotification, object: nil)
            }
        }
    }

    init() {
        fetchAllTasksFromCloudKit()
    }
    
    //MARK: - CRUD
    func addTask(named name: String, withImage image: UIImage?, activity: Activity, completion: @escaping () -> Void) {
        guard let image = image else { return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let task = Task(name: name, imageData: data, activity: activity)
        tasks.append(task)
        let record = task.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving task to CloudKit: \(error.localizedDescription)")
            } else {
                task.cloudKitRecordID = record?.recordID
            }
            completion()
        }
    }
    
    func update(task: Task, name: String, image: UIImage?, isChecked: Bool) {
        task.name = name
        //task.image = image
        task.isChecked = isChecked
        saveTaskToCloudKit(task: task) {
        }
    }
    
    func deleteTask(task: Task) {
        guard let taskRecordID = task.cloudKitRecordID else { return }
        database.delete(withRecordID: taskRecordID) { (_, error) in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
    
    func updateChildCheckedTasks(child: Child, activity: Activity, tasks: [Task], completion: () -> Void) {
        for task in tasks {
            let childName = child.cloudKitRecord.recordID.recordName
            let activityName = activity.cloudKitRecord.recordID.recordName
            let taskName = task.cloudKitRecord.recordID.recordName
            
            let childDict = UserDefaults.standard.value(forKey: childName) as? [String: Any] ?? [:]
            var childDictionary = childDict
            let checkedTasksForActivity = childDictionary[activityName] as? [String] ?? []
            
            if checkedTasksForActivity.contains(taskName) {
                task.isChecked = true
            } else {
                task.isChecked = false
            }
        }
        completion()
    }
    
    // This needs to now pass in an activity as well as a child
    func toggleIsCheckedFor(task: Task, child: Child, activity: Activity) {
        task.isChecked = !task.isChecked
        // This is the array of task record IDs that should be checked
        // Get the array of checked tasks from userDefaults
        let childName = child.cloudKitRecord.recordID.recordName
        let activityName = activity.cloudKitRecord.recordID.recordName
        let taskName = task.cloudKitRecord.recordID.recordName
        let childDict = UserDefaults.standard.value(forKey: childName) as? [String: Any] ?? [:]
        var childDictionary = childDict
        var checkedTasksForActivity = childDictionary[activityName] as? [String] ?? []
    
        if task.isChecked == true  {
            // Add the task that was just checked to the array
            checkedTasksForActivity.append(taskName)
            childDictionary[activityName] = checkedTasksForActivity
            // Save it to UserDefaults
            UserDefaults.standard.set(childDictionary, forKey: childName)
        } else {
            // Instead of checking in the child's array of checked tasks, pull out the activity's array of checked tasks from UserDefaults and do contains on that.
//            if child.checkedTasks.contains(taskReference) {
                guard let index = checkedTasksForActivity.index(of: taskName) else { return }
                // Get the array of checked tasks from userDefaults
                // Remove the task that was just checked from the array
                checkedTasksForActivity.remove(at: index)
                childDictionary[activityName] = checkedTasksForActivity

                // Save it to UserDefaults
                UserDefaults.standard.set(childDictionary, forKey: childName)
        }
    }
    
    // MARK: - Persistence
    func saveTaskToCloudKit(task: Task, completion: @escaping () -> Void) {
        let record = task.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving task to CloudKit: \(error.localizedDescription)")
            }
        }
        completion()
    }
    
    func fetchAllTasksFromCloudKit() {
        let type = Task.typeKey
        ckManager.fetchRecordsOf(type: type, database: database) { (records, error) in
            if let error = error {
                print("Error fetching tasks from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { return }
            let tasks = records.compactMap({ Task(cloudKitRecord: $0, activity: nil )})
            self.tasks = tasks
        }
    }
}
