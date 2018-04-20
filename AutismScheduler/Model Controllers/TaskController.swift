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
    var task: Task?
    var tasks: [Task] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: tasksWereSetNotification, object: nil)
            }
        }
    }
    var currentTask: Task?
    
    init() {
        fetchTasksFromCloudKit()
    }
    
    //MARK: - CRUD
    func addTask(named name: String, withImage image: UIImage?) {
        guard let image = image else { return }
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let task = Task(name: name, imageData: data)
        tasks.append(task)
        let record = task.cloudKitRecord
        ckManager.saveRecordToCloudKit(record: record, database: database) { (record, error) in
            if let error = error {
                print("Error saving task to CloudKit: \(error.localizedDescription)")
            } else {
                task.cloudKitRecordID = record?.recordID
            }
            self.saveTasksToCloudKit()
        }
    }
    
    func update(task: Task, name: String, image: UIImage?) {
        task.name = name
        //task.image = image
        saveTasksToCloudKit()
    }
    
    func deleteTask(task: Task) {
        guard let taskRecordID = task.cloudKitRecordID else { return }
        database.delete(withRecordID: taskRecordID) { (_, error) in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            } else {
                self.fetchTasksFromCloudKit()
                print("Task deleted")
            }
        }
    }
    
    // MARK: - Persistence
    func saveTasksToCloudKit() {
        let records = tasks.map({ $0.cloudKitRecord })
        ckManager.saveRecordsToCloudKit(records: records, database: database, perRecordCompletion: nil) { (records, _, error) in
            if let error = error {
                print("Error saving task records to CloudKit: \(error.localizedDescription)")
            } else {
                print("Successfully saved task records to CloudKit")
            }
        }
    }
    
    func fetchTasksFromCloudKit() {
        let type = Task.typeKey
        ckManager.fetchRecordsOf(type: type, database: database) { (records, error) in
            if let error = error {
                print("Error fetching tasks from CloudKit: \(error.localizedDescription)")
            }
            guard let records = records else { return }
            let tasks = records.compactMap({ Task(cloudKitRecord: $0 )})
            self.tasks = tasks
        }
    }
}
