//
//  UserDefaultsExtension.swift
//  AutismScheduler
//
//  Created by Steven Brown on 4/16/18.
//  Copyright © 2018 Steven Brown. All rights reserved.
//

import Foundation
import CloudKit

public extension UserDefaults {
    
    private var changeTokenKey: String {
        return "ChangeToken"
    }
    private var recordZoneKey: String {
        return "ClientRecordZone"
    }
    private var childZoneCreatedKey: String {
        return "ChildZoneID"
    }
    
    public var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: changeTokenKey) as? Data else { return nil }
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else { return nil }
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                set(data, forKey: changeTokenKey)
            } else {
                removeObject(forKey: changeTokenKey)
            }
        }
    }
    
    public var childRecordZone: CKRecordZoneID? {
        get {
            guard let data = self.value(forKey: recordZoneKey) as? Data else { return nil }
            guard let zoneID = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKRecordZoneID else { return nil }
            return zoneID
        }
        set {
            if let recordID = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: recordID)
                set(data, forKey: recordZoneKey)
            } else {
                removeObject(forKey: recordZoneKey)
            }
        }
    }
    
    public var childZoneCreated: Bool {
        get {
            if let value = self.value(forKey: childZoneCreatedKey) as? Bool {
                return value
            } else {
                return false
            }
        }
        set {
            set(newValue, forKey: childZoneCreatedKey)
        }
    }
}
