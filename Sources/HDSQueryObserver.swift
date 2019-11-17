//
//  HDSQueryObserver.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

@available(iOS 8.0, watchOS 2.0, *)
public class HDSQueryObserver: NSObject
{
    public weak var delegate: HDSQueryObserverDelegate?
    public var converter: HDSConverterProtocol? { get { return self.synchronizer.converter } set { self.synchronizer.converter = newValue } }
    public var queryPredicate: NSPredicate? { get { return self.predicate() } set { self.savePredicate(newValue) } }
    public private(set) var isObserving = false
    public var externalObjectType: HDSExternalObjectProtocol.Type { return self.synchronizer.externalObjectType }
    public var lastSuccessfulExecutionDate: Date? { get { return self.lastExecutionDate() } }
    public var canStartObserving : Bool
    {
        if let types = self.externalObjectType.authorizationTypes()
        {
            for type in types
            {
                if (self.store.authorizationStatus(for: type) == .notDetermined)
                {
                    return false
                }
            }
            
            return true
        }
        
        return false
    }
    
    private var handlerCompletions = [(query: HKObserverQuery, completion: HealthKit.HKObserverQueryCompletionHandler)]()
    private var handlerLockObject = NSObject()
    private var observerQuery: HKObserverQuery?
    private var observerLockObject = NSObject()
    private let store: HDSStoreProxyProtocol
    private let userDefaultsProxy: HDSUserDefaultsProxyProtocol
    private var synchronizer: HDSObjectSynchronizerProtocol
    private let lastExecutionKeySuffix = "-Last-Execution-Date"
    private let anchorKeySuffix = "-Anchor"
    private let predicateKeySuffix = "-Predicate"
    
    public init(store: HDSStoreProxyProtocol,
                userDefaultsProxy: HDSUserDefaultsProxyProtocol,
                synchronizer: HDSObjectSynchronizerProtocol)
    {
        self.store = store
        self.userDefaultsProxy = userDefaultsProxy
        self.synchronizer = synchronizer
    }
    
    /// Starts the observer query and enables background deliveries of HealthKit objects for the observer's authorizationTypes.
    @available(watchOS, unavailable, message: "HDSQueryObservers cannot receive background deliveries on watchOS. Use exectue() instead.")
    public func start()
    {
        guard self.store.isHealthDataAvailable() && self.canStartObserving else
        {
            return
        }
        
        objc_sync_enter(self.observerLockObject)
        
        defer
        {
            objc_sync_exit(self.observerLockObject)
        }
        
        if (self.isObserving)
        {
            return
        }
        
        if let authTypes = self.externalObjectType.authorizationTypes(), let queryType = self.externalObjectType.healthKitObjectType()
        {
            self.enableBackgroundDelivery(for: authTypes,
                                          frequency: .immediate)
            { (success, errors) in
        
                objc_sync_enter(self.observerLockObject)
                self.isObserving = success
                objc_sync_exit(self.observerLockObject)
        
                if (success)
                {
                    print("Starting observer query for " + queryType.debugDescription)
                    self.store.execute(self.query())
                }
            }
        }
    }
    
    /// Stops the observer query and disables background deliveries of HealthKit objects for the observer's authorizationTypes.
    /// All persisted data for the observer will be deleted.
    @available(watchOS, unavailable, message: "HDSQueryObservers cannot receive background deliveries on watchOS. Use exectue() instead.")
    public func stop()
    {
        guard self.store.isHealthDataAvailable() else
        {
            return
        }
        
        objc_sync_enter(self.observerLockObject)
        
        defer
        {
            objc_sync_exit(self.observerLockObject)
        }
        
        if (!self.isObserving)
        {
            return
        }
        
        if let authTypes = self.externalObjectType.authorizationTypes(), let queryType = self.externalObjectType.healthKitObjectType()
        {
            self.disableBackgroundDelivery(for: authTypes)
            { (success, errors) in
                
                print("Stopping observer query for " + queryType.debugDescription)
                self.store.stop(self.query())
                self.deleteAnchor()
                self.deleteLastExecutionDate()
                self.deletePredicate()
                
                objc_sync_enter(self.observerLockObject)
                self.isObserving = false
                objc_sync_exit(self.observerLockObject)
            }
        }
    }
    
    
    /// Forces the execution of the observer's query and synchronized data to an external store.
    ///
    /// - Parameter completion: A closure that is executed with a Bool indicating the success or failure of the operation and an optional error.
    /// - Parameter success: A bool indicating whether the operation was successful.
    /// - Parameter error: Optional - an error with details about the failure if an operation is unsuccessful.
    public func execute(completion: @escaping (_ success: Bool, _ error: Error?) -> Void = { _, _ in })
    {
        print("Execute called for type \(externalObjectType)")
        if let type = self.externalObjectType.healthKitObjectType() as? HKSampleType
        {
            if let delegate = self.delegate
            {
                delegate.shouldExecute(for: self)
                    { shouldExecute in
                    
                        if (shouldExecute)
                        {
                            self.executeAnchorQuery(type: type, completion: completion)
                        }
                        else
                        {
                            completion(false, HDSError.operationCancelled)
                        }
                }
            }
            else
            {
               self.executeAnchorQuery(type: type, completion: completion)
            }
        }
        else
        {
            completion(false, HDSError.noSpecifiedTypes)
        }
    }
    
    private func query() -> HKObserverQuery
    {
        if (self.observerQuery != nil)
        {
            return self.observerQuery!
        }
        
        if let type = self.externalObjectType.healthKitObjectType() as? HKSampleType
        {
            self.observerQuery = HKObserverQuery(sampleType: type,
                                                 predicate: self.queryPredicate,
                                                 updateHandler:
                { (query, completion, error) in
                    
                    guard error == nil else
                    {
                        print("The " + self.externalObjectType.healthKitObjectType().debugDescription + " query has returned an error. " + error!.localizedDescription)
                        return
                    }
                    
                    if (query == self.observerQuery)
                    {
                        self.handleObservedQuery(query: query, completion: completion)
                    }
            })
        }
        
        return self.observerQuery!
    }
    
    private func handleObservedQuery(query: HKObserverQuery, completion: @escaping HealthKit.HKObserverQueryCompletionHandler)
    {
        print("HandleObserverQuery called for type \(externalObjectType)")
        
        objc_sync_enter(self.handlerLockObject)
        
        defer
        {
            objc_sync_exit(self.handlerLockObject)
        }
        
        self.handlerCompletions.append((query, completion))
        
        if (self.handlerCompletions.count > 1)
        {
            // A previous observed query is still being processed.
            // To avoid executing the same observed query, handling must be performed serially.
            print("HDSQueryObserver for type '\(self.externalObjectType)' is busy - execution will be delayed.")
            return
        }
        
        if let type = query.objectType as? HKSampleType
        {
            if let delegate = self.delegate
            {
                delegate.shouldExecute(for: self)
                { shouldExecute in
                    
                    if (shouldExecute)
                    {
                        self.executeAnchorQuery(type: type)
                        { (success, error) in
                            self.completeObservedQuery()
                        }
                    }
                    else
                    {
                        self.completeObservedQuery()
                    }
                }
            }
            else
            {
                self.executeAnchorQuery(type: type)
                { (success, error) in
                    self.completeObservedQuery()
                }
            }
        }
        else
        {
            completion()
            self.completeObservedQuery()
        }
    }
    
    private func completeObservedQuery() -> Void
    {
        objc_sync_enter(self.handlerLockObject)
        if (self.handlerCompletions.count > 0)
        {
            let completion = self.handlerCompletions.remove(at: 0).completion
            completion()
        }
        
        if (self.handlerCompletions.count > 0)
        {
            let parameters = self.handlerCompletions.remove(at: 0)
            self.handleObservedQuery(query: parameters.query, completion: parameters.completion)
        }
        objc_sync_exit(self.handlerLockObject)
    }
    
    private func executeAnchorQuery(type: HKSampleType, completion: @escaping (Bool, Error?) -> Void)
    {
        let limit = self.delegate?.batchSize(for: self) ?? Constants.defaultBatchSize
        
        let anchoredQuery = HKAnchoredObjectQuery(type: type,
                                                  predicate: self.queryPredicate,
                                                  anchor: self.anchor(),
                                                  limit: limit)
        { (query, objects, deletedObjects, anchor, error) in
            
            guard error == nil else
            {
                print("The " + self.externalObjectType.healthKitObjectType().debugDescription + " anchored query has returned an error. " + error!.localizedDescription)
                completion(false, error)
                self.delegate?.didFinishExecution(for: self, error: error)
                return
            }
            
            print("Executing anchor query for \(objects!.count) object(s)")
            
            for object in objects! {
                print("Anchor query object id \(object.uuid)")
            }
            
            self.synchronizer.synchronize(objects: objects, deletedObjects: deletedObjects)
            { (error) in
                
                guard error == nil else
                {
                    print("an error occured while synchronizing " + self.externalObjectType.healthKitObjectType().debugDescription + " objects")
                    completion(false, error)
                    self.delegate?.didFinishExecution(for: self, error: error)
                    return
                }

                self.saveAnchor(anchor: anchor)
                self.saveLastExecutionDate()
                
                let count = (objects?.count ?? 0) + (deletedObjects?.count ?? 0)
                
                if count < limit
                {
                    completion(true, nil)
                    self.delegate?.didFinishExecution(for: self, error: error)
                }
                else
                {
                    print("Executing next query for type \(self.externalObjectType)")
                    self.executeAnchorQuery(type: type, completion: completion)
                }
            }
        }
        
        self.store.execute(anchoredQuery)
    }
    
    private func enableBackgroundDelivery(for types: [HKObjectType], frequency: HKUpdateFrequency, completion: @escaping (Bool, [Error]) -> Void)
    {
        var didSucceed = true
        var errors = [Error]()
        let lockObject = NSObject()

        let dispatchGroup = DispatchGroup()

        types.forEach
            { (type) in

                dispatchGroup.enter()

                self.store.enableBackgroundDelivery(for: type,
                                                    frequency: .immediate,
                                                    withCompletion:
                    { (success, error) in

                        if (success)
                        {
                            print("Enabled background delivery for " + type.debugDescription)
                        }
                        else if (error != nil)
                        {
                            didSucceed = false
                            objc_sync_enter(lockObject)
                            errors.append(error!)
                            objc_sync_exit(lockObject)
                            print("an error occured enabling background delivery for " + type.debugDescription)
                        }

                        dispatchGroup.leave()
                })
        }

        dispatchGroup.notify(queue: DispatchQueue.global())
        {
            completion(didSucceed, errors)
        }
    }

    private func disableBackgroundDelivery(for types: [HKObjectType], completion: @escaping (Bool, [Error]) -> Void)
    {
        var didSucceed = true
        var errors = [Error]()
        let lockObject = NSObject()

        let dispatchGroup = DispatchGroup()

        types.forEach
            { (type) in

                dispatchGroup.enter()

                self.store.disableBackgroundDelivery(for: type,
                                                     withCompletion:
                    { (success, error) in

                        if (success)
                        {
                            print("Disabled background delivery for " + type.debugDescription)
                        }
                        else if (error != nil)
                        {
                            didSucceed = false
                            objc_sync_enter(lockObject)
                            errors.append(error!)
                            objc_sync_exit(lockObject)
                            print("an error occured disabling background delivery for " + type.debugDescription)
                        }

                        dispatchGroup.leave()
                })
        }

        dispatchGroup.notify(queue: DispatchQueue.global())
        {
            completion(didSucceed, errors)
        }
    }
    
    /// MARK - User Defaults
    
    private func saveLastExecutionDate()
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier
        {
            self.userDefaultsProxy.set(Date(), forKey: key + self.lastExecutionKeySuffix)
        }
    }
    
    private func deleteLastExecutionDate()
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier
        {
            self.userDefaultsProxy.removeObject(forKey: key + self.lastExecutionKeySuffix)
        }
    }
    
    private func lastExecutionDate() -> Date?
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier
        {
            return self.userDefaultsProxy.object(forKey: key + self.lastExecutionKeySuffix) as? Date
        }
        
        return nil
    }
    
    private func saveAnchor(anchor: HKQueryAnchor?)
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier,
            let queryAnchor = anchor
        {
            do
            {
                let data = try NSKeyedArchiver.archivedData(withRootObject: queryAnchor, requiringSecureCoding: true)
                self.userDefaultsProxy.set(data, forKey: key + self.anchorKeySuffix)
                return
            }
            catch
            {
                print("An error occured while encoding the Anchor \(error)")
            }
        }
        
        self.deleteAnchor()
    }
    
    private func deleteAnchor()
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier
        {
            self.userDefaultsProxy.removeObject(forKey: key + self.anchorKeySuffix)
        }
    }
    
    private func anchor() -> HKQueryAnchor?
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier,
            let data = self.userDefaultsProxy.data(forKey: key + self.anchorKeySuffix)
        {
            do
            {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
            }
            catch
            {
                print("An error occured while decoding the Anchor \(error)")
            }
        }
        
        return nil
    }
    
    private func savePredicate(_ predicate: NSPredicate?)
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier,
            let queryPredicate = predicate
        {
            do
            {
                let data = try NSKeyedArchiver.archivedData(withRootObject: queryPredicate, requiringSecureCoding: true)
                self.userDefaultsProxy.set(data, forKey: key + self.predicateKeySuffix)
                return
            }
            catch
            {
                print("An error occured while encoding the Predicate \(error)")
            }
        }
        
        self.deletePredicate()
    }
    
    private func deletePredicate()
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier
        {
            self.userDefaultsProxy.removeObject(forKey: key + self.predicateKeySuffix)
        }
    }
    
    private func predicate() -> NSPredicate?
    {
        if let key = self.externalObjectType.healthKitObjectType()?.identifier,
            let data = self.userDefaultsProxy.data(forKey: key + self.predicateKeySuffix)
        {
            do
            {
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPredicate.self, from: data)
            }
            catch
            {
                print("An error occured while decoding the Predicate \(error)")
            }
        }
        
        return nil
    }
}

#endif
