//
//  HDSManager.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

@available(iOS 8.0, watchOS 2.0, *)
open class HDSManager : NSObject, HDSManagerProtocol
{
    open var observerDelegate: HDSQueryObserverDelegate?
    {
        didSet
        {
            objc_sync_enter(self.synchronizerLockObject)
            self.allObservers.forEach
                { observer in
                    
                    observer.delegate = self.observerDelegate;
            }
            objc_sync_exit(self.synchronizerLockObject)
        }
    }
    open var converter: HDSConverterProtocol?
    {
        didSet
        {
            objc_sync_enter(self.synchronizerLockObject)
            self.allObservers.forEach
                { observer in
                    
                    observer.converter = self.converter;
            }
            objc_sync_exit(self.synchronizerLockObject)
        }
    }
    public private(set) var allObservers: [HDSQueryObserver]
    private let store: HDSStoreProxyProtocol
    private let userDefaults: HDSUserDefaultsProxyProtocol
    private let permissionsManager: HDSPermissionsManager
    private let observerFactory: HDSQueryObserverFactory
    private let synchronizerLockObject = NSObject()
    
    public init(store: HDSStoreProxyProtocol,
              userDefaults: HDSUserDefaultsProxyProtocol,
              permissionsManager: HDSPermissionsManager,
              observerFactory: HDSQueryObserverFactory)
    {
        self.store = store
        self.userDefaults = userDefaults
        self.permissionsManager = permissionsManager
        self.observerFactory = observerFactory
        self.allObservers = [HDSQueryObserver]()
        
        super.init()
    }
    
    open func requestPermissionsForAllObservers(completion:@escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        objc_sync_enter(self.synchronizerLockObject)
        self.requestPermissions(with: self.allObservers, completion)
        objc_sync_exit(self.synchronizerLockObject)
    }
    
    open func requestPermissions(with observers: [HDSQueryObserver], _ completion:@escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        self.permissionsManager.readTypes = self.authorizationTypes(from: observers)
        self.permissionsManager.authorizeHealthKit(completion)
    }
    
    open func addObjectTypes(_ objectTypes: [HDSExternalObjectProtocol.Type], externalStore: HDSExternalStoreProtocol)
    {
        objc_sync_enter(self.synchronizerLockObject)
        let observers = objectTypes.reduce( [HDSQueryObserver](),
            { result, objectType in
                
                var mutableResult = result
                
                if (!self.hasObserver(for: objectType))
                {
                    let synchronizer = HDSObjectSynchronizer(externalObjectType:objectType, store: self.store, externalStore: externalStore)
                    let observers = self.observerFactory.observers(with: [synchronizer])
                    observers.forEach { observer in observer.delegate = self.observerDelegate; }
                    mutableResult.append(contentsOf: observers)
                }
                
                return mutableResult;
        })
        self.allObservers.append(contentsOf: observers)
        objc_sync_exit(self.synchronizerLockObject)
    }
    
    open func addSynchronizers(_ synchronizers: [HDSObjectSynchronizerProtocol])
    {
        objc_sync_enter(self.synchronizerLockObject)
        let observers = self.observerFactory.observers(with: synchronizers.filter { synchronizer in !self.hasObserver(for: synchronizer.externalObjectType) })
        observers.forEach { observer in observer.delegate = self.observerDelegate; }
        self.allObservers.append(contentsOf: observers)
        objc_sync_exit(self.synchronizerLockObject)
    }
    
    open func startObserving()
    {
        objc_sync_enter(self.synchronizerLockObject)
        self.allObservers.forEach(
            { (observer) in
                
                observer.start()
        })
        objc_sync_exit(self.synchronizerLockObject)
    }
    
    open func stopObserving()
    {
        objc_sync_enter(self.synchronizerLockObject)
        self.allObservers.forEach(
            { (observer) in
                
                observer.stop()
        })
        objc_sync_exit(self.synchronizerLockObject)
    }
    
    open func sources(for observers: [HDSQueryObserver], completion:@escaping ([HDSQueryObserver : Set<HKSource>], [Error]?) -> Void)
    {
        let dispatchGroup = DispatchGroup()
        let lockObject = NSObject()
        var sourcesDictionary = [HDSQueryObserver : Set<HKSource>]()
        var errors = [Error]()
        
        objc_sync_enter(self.synchronizerLockObject)
        observers.forEach
            { (observer) in
            
                if let type = observer.externalObjectType.healthKitObjectType() as? HKSampleType
                {
                    dispatchGroup.enter()
                    
                    let query = HKSourceQuery(sampleType: type,
                                              samplePredicate: nil,
                                              completionHandler:
                        { (query, sources, error) in
                            
                            if (error != nil)
                            {
                                objc_sync_enter(lockObject)
                                errors.append(error!)
                                objc_sync_exit(lockObject)
                            }
                            else if (sources != nil)
                            {
                                objc_sync_enter(lockObject)
                                sourcesDictionary[observer] = sources
                                objc_sync_exit(lockObject)
                            }

                            dispatchGroup.leave()
                    })
                    
                    self.store.execute(query)
                }
        }
        objc_sync_exit(self.synchronizerLockObject)
        
        dispatchGroup.notify(queue: DispatchQueue.global())
        {
            completion(sourcesDictionary, errors)
        }
    }
    
    private func authorizationTypes(from observers: [HDSQueryObserver]) -> [HKObjectType]
    {
        var types = [HKObjectType]()
     
        objc_sync_enter(self.synchronizerLockObject)
        observers.forEach
            { (observer) in
                
                observer.externalObjectType.authorizationTypes()?.forEach(
                    { (type) in
                        
                        types.append(type)
                })
        }
        objc_sync_exit(self.synchronizerLockObject)
        
        return types
    }
    
    // Helpers
    
    private func hasObserver(for objectType: HDSExternalObjectProtocol.Type) -> Bool
    {
        return self.allObservers.contains(where: { return objectType.authorizationTypes() == $0.externalObjectType.authorizationTypes() && objectType.healthKitObjectType() == $0.externalObjectType.healthKitObjectType() })
    }
}

#endif
