//
//  CloudKitManager.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/17/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    
    //SAVES ONE RECORD AT A TIME
    func saveRecordToCloudKit(record: CKRecord,
                              database: CKDatabase,
                              completion: @escaping (CKRecord?, Error?) -> Void ) {
        saveRecordsToCloudKit(records: [record], database: database, perRecordCompletion: nil) { (records, _, error) in
            completion(records?.first, error)
        }
    }
    
    //SAVES AN ARRAY OF RECORDS AT THE SAME TIME
    func saveRecordsToCloudKit(records: [CKRecord],
                               database: CKDatabase,
                               perRecordCompletion: ((CKRecord?, Error?) -> Void)?,
                               completion: (([CKRecord]?, [CKRecordID]?, Error?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: records,
                                                 recordIDsToDelete: nil)
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        operation.savePolicy = .changedKeys
        operation.perRecordCompletionBlock = perRecordCompletion
        operation.modifyRecordsCompletionBlock = completion
        database.add(operation)
    }
    
    //FETCHES ALL RECORDS AT THE SAME TIME
    func fetchRecordsOf(type: String,
                        predicate: NSPredicate = NSPredicate(value: true),
                        database: CKDatabase,
                        completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let query = CKQuery(recordType: type, predicate: predicate)
        database.perform(query,
                         inZoneWith: nil,
                         completionHandler: completion)
    }
    
    //SUBSCRIBES
    func subscribeToCreationOfRecordsOf(type: String,
                                        database: CKDatabase,
                                        predicate: NSPredicate = NSPredicate(value: true),
                                        withNotificationTitle title: String?,
                                        alertBody: String?,
                                        andSoundName soundName: String?,
                                        completion: @escaping (CKSubscription?, Error?) -> Void) {
        let subscription = CKQuerySubscription(recordType: type,
                                               predicate: predicate,
                                               options: .firesOnRecordCreation)
        let notificationInfo = CKNotificationInfo()
        notificationInfo.title = title
        notificationInfo.alertBody = alertBody
        notificationInfo.soundName = soundName
        subscription.notificationInfo = notificationInfo
        database.save(subscription, completionHandler: completion)
    }
    
    // MARK: - Sharing
    var sharingZoneID: CKRecordZoneID = {
        return CKRecordZoneID(zoneName: "sharingZone",
                              ownerName: CKCurrentUserDefaultName)
    }()
    
    func createSharingZone() {
        let sharingZoneHasBeenCreatedKey = "sharingZoneHasBeenCreated"
        guard UserDefaults.standard.bool(forKey: sharingZoneHasBeenCreatedKey) == false  else { return }
        let sharingZone = CKRecordZone(zoneID: sharingZoneID)
        let modifyZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: [sharingZone], recordZoneIDsToDelete: nil)
        modifyZonesOperation.modifyRecordZonesCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error saving sharing zone to CloudKit: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(true, forKey: sharingZoneHasBeenCreatedKey)
            }
        }
        CKContainer.default().privateCloudDatabase.add(modifyZonesOperation)
    }
    
    func createCloudSharingControllerWith(cloudKitSharable: CloudKitSharable) -> UICloudSharingController {
        let cloudSharingController = UICloudSharingController { (cloudSharingController, preparationCompletionHandler) in
            cloudSharingController.availablePermissions = []
            let share = CKShare(rootRecord: cloudKitSharable.cloudKitRecord)
            share.setValue(cloudKitSharable.title, forKey: CKShareTitleKey)
            share.setValue(kCFBundleIdentifierKey, forKey: CKShareTypeKey)
            CloudKitManager.shared.saveRecordsToCloudKit(records: [cloudKitSharable.cloudKitRecord, share], database: CKContainer.default().privateCloudDatabase, perRecordCompletion: nil, completion: { (_, _, error) in
                if let error = error {
                    print("Error saving share: \(error.localizedDescription)")
                }
                preparationCompletionHandler(share, CKContainer.default(), error)
            })
        }
        return cloudSharingController
    }
    
    func acceptShareWith(cloudKitShareMetadata: CKShareMetadata, completion: @escaping () -> Void) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptShareOperation.qualityOfService = .userInteractive
        var savedZoneIDs: [[String: String]] = UserDefaults.standard.value(forKey: "sharedRecordUserRecordIDs") as? [[String: String]] ?? []
        acceptShareOperation.perShareCompletionBlock = { (metadata, share, error) in
            if let error = error { print(error.localizedDescription) }
            savedZoneIDs.append(metadata.rootRecordID.zoneID.dictionaryRepresentation)
        }
        acceptShareOperation.acceptSharesCompletionBlock = { error in
            if let error = error { print(error.localizedDescription) }
            UserDefaults.standard.set(savedZoneIDs, forKey: "sharedRecordUserRecordIDs")
            completion()
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
    }
    
    func fetchSharedRecords(completion: @escaping ([CKRecord]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Entry", predicate: predicate)
        guard let zoneIDDictionaries = UserDefaults.standard.value(forKey: "sharedRecordUserRecordIDs") as? [[String: String]], zoneIDDictionaries.count > 0 else { completion([]); return }
        let zoneIDs = zoneIDDictionaries.compactMap({ CKRecordZoneID(dictionary: $0) })
        let group = DispatchGroup()
        var sharedRecords: [CKRecord] = []
        for zoneID in zoneIDs {
            group.enter()
            CKContainer.default().sharedCloudDatabase.perform(query, inZoneWith: zoneID) { (records, error) in
                if let error = error { print("Error fetching shared records: \(error.localizedDescription)") }
                guard let records = records else { return }
                sharedRecords.append(contentsOf: records)
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            completion(sharedRecords)
        }
    }
    
    // MARK: - User Discoverability
    func requestDiscoverabilityAuthorization(completion: @escaping(CKApplicationPermissionStatus, Error?) -> Void) {
        CKContainer.default().status(forApplicationPermission: .userDiscoverability) { (permissionStatus, error) in
            guard permissionStatus != .granted else { completion(.granted, error); return }
            CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: completion)
        }
    }
    
    func fetchUserIdentityWith(email: String, completion: @escaping (CKUserIdentity?, Error?) -> Void) {
        CKContainer.default().discoverUserIdentity(withEmailAddress: email, completionHandler: completion)
    }
    
    func fetchUserIdentityWith(phoneNumber: String, completion: @escaping (CKUserIdentity?, Error?) -> Void) {
        CKContainer.default().discoverUserIdentity(withPhoneNumber: phoneNumber, completionHandler: completion)
    }
}

extension CKRecordZoneID {
    var dictionaryRepresentation: [String: String] {
        return ["zoneName": zoneName, "ownerName": ownerName]
    }
    
    convenience init?(dictionary: [String: String]) {
        guard let zoneName = dictionary["zoneName"],
            let ownerName = dictionary["ownerName"] else { return nil}
        self.init(zoneName: zoneName, ownerName: ownerName)
    }
}

protocol CloudKitSharable {
    var title: String { get set }
    var cloudKitRecord: CKRecord { get }
}
