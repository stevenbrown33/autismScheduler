//
//  CloudKitSynchable.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

///The default implementation will take care of stored properties on the model object, but does not handle relationships. Conforming classes should provide implementations of addCKReferencesToCKRecord and initializeRelationshipsFromReferences to set up their relationships as appropriate.  These functions will automatically be called at the appropriate time.
protocol CloudKitSynchable: class {
    ///This should be a unique string that identifies the record for the model object in CloudKit.
    var recordName: String? { get set }
    var asCKRecord: CKRecord? { get }
    var lastModificationTimestamp: Double { get }
    ///Stored properties are automatically handled by the default implemtation of asCKRecord.  This method is a hook for conforming classes to use to add CKReferences to their record as needed to maintain their relationships when restored from a CKRecord.
    func addCKReferencesToCKRecord(_ record: CKRecord)
    ///Initializing stored properties of a model object is handled by the default implementation of modelObject(from:), but references cannot be automatically handled by that implementation.  This function is a hook for conforming classes to initialize their relationships with other model objects based on the references found in the provided CKRecord. Return true if all required relationships were successfully initialized, false otherwise.
    static func initializeRelationshipsFromReferences(_ record: CKRecord, model: Self) -> Bool
    static var recordType: String { get }
    static func updateModel(from record: CKRecord, in context: NSManagedObjectContext) -> Self?
}

extension CloudKitSynchable {
    static var recordType: String {
        return String(describing: Self.self)
    }
}

//Gives all of the managed objects a baseline implentation that deals with all of their stored properties
extension CloudKitSynchable where Self: NSManagedObject {
    
    //Empty implementation to make implementing this function optional for conforming types. This is because, per CloudKit guidlines, the parent object will not have a reference to the child object and therefore there will be no work to do here.
    func addCKReferencesToCKRecord(_ record: CKRecord){}
    static func initializeRelationshipsFromReferences(_ record: CKRecord, model: Self) -> Bool { return true }
    
    var asCKRecord: CKRecord? {
        var record: CKRecord
        self.recordName = self.recordName != nil ? self.recordName! : UUID().uuidString
        guard let zoneID = UserDefaults.standard.childRecordZone else { return nil }
        let recordID = CKRecordID(recordName: self.recordName!, zoneID: zoneID)
        record = CKRecord(recordType: Self.recordType, recordID: recordID)
        let attributes = entity.attributesByName
        for attribute in attributes {
            let name = attribute.key
            guard let recordValue = self.value(forKey: name) as? CKRecordValue else { continue }
            record[name] = recordValue
        }
        addCKReferencesToCKRecord(record)
        return record
    }
    
    static func updateModel(from record: CKRecord, in context: NSManagedObjectContext) -> Self? {
        let fetchRequest = NSFetchRequest<Self>(entityName: Self.recordType)
        let predicate = NSPredicate(format: "recordName == %@", record.recordID.recordName)
        fetchRequest.predicate = predicate
        let matchingObjects = (try? context.fetch(fetchRequest))
        guard let matchingObject = matchingObjects?.first else {
            return createNewModel(from: record, in: context)
        }
        guard let recordTimestamp = record.value(forKey: "lastModificationTimestamp") as? Double,recordTimestamp > matchingObject.lastModificationTimestamp else {
            return matchingObject
        }
        guard initializeRelationshipsFromReferences(record, model: matchingObject) else {
            NSLog("Potentially Serious Error: Could set up relationships from CKRecord for existing object. Returning unmodified object.")
            return matchingObject
        }
        updateObjectStoredProperties(from: record, object: matchingObject)
        do {
            try context.save()
        } catch let error {
            NSLog("Failed to save updated model after loading from CloudKit. Error: \(error.localizedDescription)")
        }
        return matchingObject
    }
    
    private static func createNewModel(from record: CKRecord, in context: NSManagedObjectContext) -> Self? {
        let object = Self.init(context: context)
        updateObjectStoredProperties(from: record, object: object)
        guard initializeRelationshipsFromReferences(record, model: object) else { return nil }
        do {
            try context.save()
        } catch let error {
            NSLog("Failed to save model initialized from CloudKit. Error: \(error.localizedDescription)")
        }
        return object
    }
    
    private static func updateObjectStoredProperties(from record: CKRecord, object: Self){
        for key in record.allKeys() {
            let value = record[key]
            //This is so that we will only try to initialize stored properties from the record at this time as relationships must be handled separately.
            if object.entity.attributesByName.keys.contains(key){
                object.setValue(value, forKey: key)
            }
        }
    }
}
