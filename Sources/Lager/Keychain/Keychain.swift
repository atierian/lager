//
//  File.swift
//  
//
//  Created by Ian Saultz on 7/12/22.
//

import Foundation

extension String {
    
    init(_ cfString: CFString) {
        self = cfString as String
    }
    
    static let secMatchLimit = String(kSecMatchLimit)
    static let secReturnData = String(kSecReturnData)
    static let secReturnPersistentRef = String(kSecReturnPersistentRef)
    static let secValueData = String(kSecValueData)
    static let secAttrAccessible = String(kSecAttrAccessible)
    static let secClass = String(kSecClass)
    static let secAttrService = String(kSecAttrService)
    static let secAttrGeneric = String(kSecAttrGeneric)
    static let secAttrAccount = String(kSecAttrAccount)
    static let secAttrAccessGroup = String(kSecAttrAccessGroup)
    static let secReturnAttributes = String(kSecReturnAttributes)
}

public struct Keychain {
    static var service: String = "com.hello"
    static var accessGroup: String? = nil
    
    public static func set(
        _ data: Data,
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws {
        var query = queryDict(
            forKey: key,
            withAccessibilitiy: accessibility
        )
        
        query[.secValueData] = data
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        switch status {
        case errSecSuccess: return
        case errSecDuplicateItem:
            try update(data, forKey: key, withAccessibilitiy: accessibility)
        default: throw NSError()
        }
    }
    
    public static func update(
        _ value: Data,
        forKey key: String,
        withAccessibilitiy accessibility: Accessibility
    ) throws {
        let query = queryDict(
            forKey: key,
            withAccessibilitiy: accessibility
        )
        let update: [String: Any] = [.secValueData: value]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            update as CFDictionary
        )
        
        if status != errSecSuccess {
            throw NSError()
        }
    }
    
    public static func int(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> Int {
        guard let n = try object(forKey: key, withAccessibility: accessibility) as? NSNumber
        else {
            throw NSError()
        }
        return n.intValue
    }
    
    public static func float(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> Float {
        guard let n = try object(forKey: key, withAccessibility: accessibility) as? NSNumber
        else {
            throw NSError()
        }
        return n.floatValue
    }
    
    public static func double(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> Double {
        guard let n = try object(forKey: key, withAccessibility: accessibility) as? NSNumber
        else {
            throw NSError()
        }
        return n.doubleValue
    }
    
    public static func bool(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> Bool {
        guard let n = try object(forKey: key, withAccessibility: accessibility) as? NSNumber
        else {
            throw NSError()
        }
        return n.boolValue
    }
    
    public static func string(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> String {
        let data = try data(
            forKey: key,
            withAccessibility: accessibility
        )
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError()
        }
        
        return string
    }
    
    public static func object(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> NSCoding {
        let data = try data(
            forKey: key,
            withAccessibility: accessibility
        )
        
        guard
            let coding = try NSKeyedUnarchiver
                .unarchiveTopLevelObjectWithData(data) as? NSCoding
        else {
            throw NSError()
        }
        
        return coding
    }
    
    public static func data(
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws -> Data {
        var query = queryDict(
            forKey: key,
            withAccessibilitiy: accessibility
        )
        
        query[.secMatchLimit] = kSecMatchLimitOne
        query[.secReturnData] = kCFBooleanTrue
        
        let pointer = UnsafeMutablePointer<CFTypeRef?>.allocate(capacity: 1)
        
        let status = SecItemCopyMatching(
            query as CFDictionary,
            pointer
        )
        
        if status != noErr {
            throw NSError()
        }
        
        guard let data = pointer.pointee as? Data
        else { throw NSError() }
        
        return data
    }
    
    static private func queryDict(
        forKey key: String,
        withAccessibilitiy accessibility: Accessibility
    ) -> [String: Any] {
        let identifier = Data(key.utf8)
        var query: [String: Any] = [
            .secClass: kSecClassGenericPassword,
            .secAttrService: Self.service,
            .secAttrAccessible: accessibility.kSecAttrAccessible,
            .secAttrGeneric: identifier,
            .secAttrAccount: identifier
        ]
        
        if let accessGroup = Self.accessGroup {
            query[.secAttrAccessGroup] = accessGroup
        }
        
        return query
    }
    
    static public func set(
        _ value: Bool,
        forKey key: String,
        withAccessibility accessibility: Accessibility = .whenUnlocked
    ) throws {
        try set(
            NSNumber(value: value),
            forKey: key,
            withAccessibility: accessibility
        )
    }
    
    public static func set(
        _ value: NSCoding,
        forKey key: String,
        withAccessibility accessibility: Accessibility
    ) throws {
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: value,
            requiringSecureCoding: false
        )
        
        try set(
            data,
            forKey: key,
            withAccessibility: accessibility
        )
    }
    
    public static func delete(key: String, withAccessibility accessibility: Accessibility) throws {
        let query = queryDict(
            forKey: key,
            withAccessibilitiy: accessibility
        )
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw NSError()
        }
    }
    
    public static func wipe(_ classes: CFString...) throws {
        try classes.forEach(deleteData(forSecClass:))
    }
    
    private static func deleteData(forSecClass secClass: AnyObject) throws {
        let query: [String: AnyObject] = [
            .secClass: secClass
        ]
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess {
            throw NSError()
        }
    }
    
//    init(service: String, accessGroup: String?) {
//        self.service = service
//        self.accessGroup = accessGroup
//    }
}



extension Keychain {
    public struct Accessibility {
        let kSecAttrAccessible: CFString
        
        init(_ kSecAttrAccessible: CFString) {
            self.kSecAttrAccessible = kSecAttrAccessible
        }
        
        public static let afterFirstUnlock = Accessibility(
            kSecAttrAccessibleAfterFirstUnlock
        )
        
        public static let afterFirstUnlockThisDeviceOnly = Accessibility(
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        )
        
        public static let always = Accessibility(
            kSecAttrAccessibleAlways
        )
        
        public static let whenPasscodeSetThisDeviceOnly = Accessibility(
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        )
        
        public static let alwaysThisDeviceOnly = Accessibility(
            kSecAttrAccessibleAlwaysThisDeviceOnly
        )
        
        public static let whenUnlocked = Accessibility(
            kSecAttrAccessibleWhenUnlocked
        )
        
        public static let whenUnlockedThisDeviceOnly = Accessibility(
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )
    }
}
