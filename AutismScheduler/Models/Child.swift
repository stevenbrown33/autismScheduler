//
//  Child.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/17/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class Child {
    
    // MARK: - Properties
    static let nameKey = "name"
    static let imageDataKey = "imageData"
    static let typeKey = "Child"
    static let checkedActivitiesRefKey = "checkedActivities"
    static let checkedTasksRefKey = "checkedTasks"
    
    var name: String
    var imageData: Data?
    var activities: [Activity]
    var checkedActivities: [CKReference]
    //var checkedTasks: [CKReference]
    
    var recordType: String { return Child.typeKey }
    var cloudKitRecordID: CKRecordID?
    var image: UIImage? {
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    init(name: String, imageData: Data?, activites: [Activity] = [], checkedActivities: [CKReference] = []) {
        self.name = name
        self.imageData = imageData
        self.activities = activites
        self.checkedActivities = checkedActivities
    }
    
    convenience required init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Child.nameKey] as? String,
            let imageAsset = cloudKitRecord[Child.imageDataKey] as? CKAsset else { return nil }
        let imageData = try? Data(contentsOf: imageAsset.fileURL)
        let checkedActivities = cloudKitRecord[Child.checkedActivitiesRefKey] as? [CKReference] ?? []
        self.init(name: name, imageData: imageData, checkedActivities: checkedActivities)
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let recordName = UUID().uuidString
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: recordName)
        let recordType = Child.typeKey
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record.setValue(name, forKey: Child.nameKey)
        record.setValue(CKAsset(fileURL: temporaryImageURL), forKey: Child.imageDataKey)
        if checkedActivities.count > 0 {
            record.setValue(checkedActivities, forKey: Child.checkedActivitiesRefKey)
        }
        cloudKitRecordID = recordID
        return record
    }
    
    fileprivate var temporaryImageURL: URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try? imageData?.write(to: fileURL, options: [.atomic])
        return fileURL
    }
}
