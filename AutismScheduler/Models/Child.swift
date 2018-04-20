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
    
    var name: String
    var imageData: Data?
    var activites: [Activity]
    var recordType: String { return Child.typeKey }
    var cloudKitRecordID: CKRecordID?
    var image: UIImage? {
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    init(name: String, imageData: Data?, activites: [Activity] = []) {
        self.name = name
        self.imageData = imageData
        self.activites = activites
    }
    
    convenience required init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Child.nameKey] as? String,
            let imageAsset = cloudKitRecord[Child.imageDataKey] as? CKAsset else { return nil }
        let imageData = try? Data(contentsOf: imageAsset.fileURL)
        self.init(name: name, imageData: imageData)
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let recordName = UUID().uuidString
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: recordName)
        let recordType = Child.typeKey
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record[Child.nameKey] = name as CKRecordValue
        record[Child.imageDataKey] = CKAsset(fileURL: temporaryImageURL)
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
