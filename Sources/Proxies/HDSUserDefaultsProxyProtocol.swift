//
//  HDSUserDefaultsProxyProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public protocol HDSUserDefaultsProxyProtocol
{
    /*!
     -setObject:forKey: immediately stores a value (or removes the value if nil is passed as the value) for the provided key in the search list entry for the receiver's suite name in the current user and any host, then asynchronously stores the value persistently, where it is made available to other processes.
     */
    func set(_ value: Any?, forKey defaultName: String)
    
    /// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:defaultName]
    func removeObject(forKey defaultName: String)
    
    /// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
    func data(forKey defaultName: String) -> Data?
    
    /*!
     -objectForKey: will search the receiver's search list for a default with the key 'defaultName' and return it. If another process has changed defaults in the search list, NSUserDefaults will automatically update to the latest values. If the key in question has been marked as ubiquitous via a Defaults Configuration File, the latest value may not be immediately available, and the registered value will be returned instead.
     */
    func object(forKey defaultName: String) -> Any?
}
