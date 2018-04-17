//
//  Child.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/17/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class Child2 {
    private let nameKey = "name"
    private let imageKey = "image"
    static let typeKey = "Child"
    
    let name: String
    let image: UIImage?
    var activites: [Activity]
    var cloudKitRecordID: CKRecordID?
    
    init(name: String, image: UIImage?, activites: [Activity] = []) {
        self.name = name
        self.image = image
        self.activites = activites
    }
    
    var cloudKitRecord: CKRecord {
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: Child2.typeKey, recordID: recordID)
        record.setValue(name, forKey: nameKey)
        return record
    }
}
