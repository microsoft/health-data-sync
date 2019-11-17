//
//  MockUserDefaults.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockUserDefaults : HDSUserDefaultsProxyProtocol {
    public var setParams = [(value: Any?, defaultName: String)]()
    public var removeObjectParams = [String]()
    public var dataParams = [String]()
    public var dataReturns = [Data?]()
    public var objectParams = [String]()
    public var objectReturns = [Any?]()
    
    public func set(_ value: Any?, forKey defaultName: String) {
        setParams.append((value, defaultName))
    }
    
    public func removeObject(forKey defaultName: String) {
        removeObjectParams.append(defaultName)
    }
    
    public func data(forKey defaultName: String) -> Data? {
        dataParams.append(defaultName)
        if dataReturns.count > 0 {
            return dataReturns.removeFirst()
        }
        
        return setParams.first?.value as? Data
    }
    
    public func object(forKey defaultName: String) -> Any? {
        objectParams.append(defaultName)
        return objectReturns.removeFirst()
    }
    
    
}
