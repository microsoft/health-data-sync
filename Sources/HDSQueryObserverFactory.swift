//
//  HDSQueryObserverFactory.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class HDSQueryObserverFactory : NSObject
{
    private let store: HDSStoreProxyProtocol
    private let userDefaults: HDSUserDefaultsProxyProtocol
    
    public init(store: HDSStoreProxyProtocol, userDefaults: HDSUserDefaultsProxyProtocol)
    {
        self.store = store
        self.userDefaults = userDefaults
    }
    
    internal func observers(with synchronizers:[HDSObjectSynchronizerProtocol]) -> [HDSQueryObserver]
    {
        var observers = [HDSQueryObserver]()
        
        synchronizers.forEach
            { (synchronizer) in
            
                let observer = HDSQueryObserver(store: self.store,
                                                userDefaultsProxy: self.userDefaults,
                                                synchronizer:synchronizer)
                
                observers.append(observer)
        }
        
        return observers
    }
}
