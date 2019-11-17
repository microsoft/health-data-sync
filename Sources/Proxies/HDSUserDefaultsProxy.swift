//
//  HDSUserDefaultsProxy.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class HDSUserDefaultsProxy: HDSUserDefaultsProxyProtocol
{
    private var userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults)
    {
        self.userDefaults = userDefaults
    }
    
    public func set(_ value: Any?, forKey defaultName: String)
    {
        self.userDefaults.set(value, forKey: defaultName)
    }
    
    public func removeObject(forKey defaultName: String)
    {
        self.userDefaults.removeObject(forKey: defaultName)
    }
    
    public func data(forKey defaultName: String) -> Data?
    {
        return self.userDefaults.data(forKey: defaultName)
    }
    
    public func object(forKey defaultName: String) -> Any?
    {
        return self.userDefaults.object(forKey:defaultName)
    }
}
