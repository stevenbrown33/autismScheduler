//
//  Task.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/17/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class Task {
    private let nameKey = "name"
    private let imageKey = "image"
    private let childRefKey = "childRef"
    static let typeKey = "Task"
    
    let name: String
    let image: UIImage?
    weak var child: Child?
    var cloudKitRecordID: CKRecordID?
    
    init(name: String, image: UIImage?, child: Child?) {
        self.name = name
        self.image = image
        self.child = child
    }
    
    init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[nameKey] as? String,
            let image = cloudKitRecord[imageKey] as? UIImage else { return nil }
        self.name = name
        self.image = image
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let recordType = Task.typeKey
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record.setValue(name, forKey: nameKey)
        record.setValue(image, forKey: imageKey)
        if let child = child,
            let childRecordID = child.cloudKitRecordID {
            let childReference = CKReference(recordID: childRecordID, action: .deleteSelf)
            record.setValue(childReference, forKey: childRefKey)
        }
        return record
    }
}
