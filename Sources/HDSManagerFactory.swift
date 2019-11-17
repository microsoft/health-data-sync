//
//  HDSManagerFactory.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

public class HDSManagerFactory: NSObject
{
    static private var _manager: HDSManagerProtocol?
    static private var instanceLock = NSObject()
    
    static public func manager() -> HDSManagerProtocol
    {
        objc_sync_enter(instanceLock)
        
        defer
        {
            objc_sync_exit(instanceLock)
        }
        
        if (_manager != nil)
        {
            return _manager!
        }
        
        let store = HDSStoreProxy(store: HKHealthStore())
        let userDefaults = HDSUserDefaultsProxy(userDefaults: UserDefaults.standard)
        let permissionsManager = HDSPermissionsManager(store: store)
        
        _manager = HDSManager(store: store,
                             userDefaults: userDefaults,
                             permissionsManager: permissionsManager,
                             observerFactory: HDSQueryObserverFactory(store: store, userDefaults: userDefaults))

        return _manager!
    }
}

#endif
