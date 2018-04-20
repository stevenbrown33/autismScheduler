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
    
    //MARK: - Properties
    static let nameKey = "name"
    static let imageDataKey = "imageData"
    static let childRefKey = "childRef"
    static let activityRefKey = "activityRef"
    static let typeKey = "Task"
    
    weak var child: Child?
    var name: String
    var image: UIImage? {
        guard let imageData = self.imageData else { return nil }
        return UIImage(data: imageData)
    }
    let imageData: Data?
    var recordType: String { return Task.typeKey }
    var cloudKitRecordID: CKRecordID?
    
    init(name: String, imageData: Data?) {
        self.name = name
        self.imageData = imageData
    }
    
    convenience required init?(cloudKitRecord: CKRecord) {
        guard let name = cloudKitRecord[Task.nameKey] as? String,
            let imageAsset = cloudKitRecord[Task.imageDataKey] as? CKAsset else { return nil }
        let imageData = try? Data(contentsOf: imageAsset.fileURL)
        self.init(name: name, imageData: imageData)
        self.cloudKitRecordID = cloudKitRecord.recordID
    }
    
    var cloudKitRecord: CKRecord {
        let recordName = UUID().uuidString
        let recordID = cloudKitRecordID ?? CKRecordID(recordName: recordName)
        let recordType = Task.typeKey
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record[Task.nameKey] = name as CKRecordValue
        record[Task.imageDataKey] = CKAsset(fileURL: temporaryImageURL)
        cloudKitRecordID = recordID
        //        if let child = child,
        //            let childRecordID = child.cloudKitRecordID {
        //            let childReference = CKReference(recordID: childRecordID, action: .deleteSelf)
        //            record.setValue(childReference, forKey: childRefKey)
        //        }
        return record
    }
    
    fileprivate var temporaryImageURL: URL {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let pathComponent = UUID().uuidString
        let fileURL = temporaryDirectoryURL.appendingPathComponent(pathComponent).appendingPathExtension("jpg")
        try? imageData?.write(to: fileURL, options: [.atomic])
        return fileURL
    }
}
