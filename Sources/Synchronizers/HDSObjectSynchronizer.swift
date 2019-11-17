//
//  HDSObjectSynchronizer.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

open class HDSObjectSynchronizer: HDSObjectSynchronizerProtocol
{
    open private(set) var externalObjectType: HDSExternalObjectProtocol.Type
    open var unitsDictionary: [HKQuantityType : HKUnit]?
    public var converter: HDSConverterProtocol?
    private let store: HDSStoreProxyProtocol
    private let externalObjectStore: HDSExternalStoreProtocol
    
    public init(externalObjectType: HDSExternalObjectProtocol.Type,
                store: HDSStoreProxyProtocol,
                externalStore: HDSExternalStoreProtocol)
    {
        self.externalObjectType = externalObjectType
        self.store = store
        self.externalObjectStore = externalStore
    }
    
    open func synchronize(objects: [HKObject]?, deletedObjects: [HKDeletedObject]?, completion: @escaping (Error?) -> Void)
    {
        // Give subclasses an opportunity to execute code before syncing
        self.willSyncronize(objects: objects, deletedObjects: deletedObjects)
        {
            // First process any deleted objects
            self.delete(deletedObjects: deletedObjects)
            { (error) in
                
                guard error == nil else
                {
                    completion(error)
                    return
                }
                
                // Next process any updates and/or creates
                self.createOrUpdate(objects: objects, completion:
                { (error) in
                    
                    // Give subclasses an opportunity to execute code after syncing
                    self.willFinishSyncronizing(after:
                        {
                            completion(error)
                    })
                })
            }
        }
    }
    
    private func delete(deletedObjects: [HKDeletedObject]?, completion: @escaping (Error?) -> Void)
    {
        guard let deleted = deletedObjects,
            deleted.count > 0 else {
                completion(nil)
                return
        }
        
        // Create an array of external objects from the deleted objects
        let externalObjects = deleted.compactMap({ self.externalObjectType.externalObject(deletedObject: $0, converter: self.converter) })
        
        // Fetch the objects from the external store
        self.fetchExternalObjects(with: externalObjects)
        { (externalObjects, error) in
            
            if (externalObjects != nil && !externalObjects!.isEmpty)
            {
                // Delete the objects from the external store
                self.externalObjectStore.delete(deletedObjects: externalObjects!, completion: completion)
            }
            else
            {
                completion(error)
            }
        }
    }
    
    private func createOrUpdate(objects: [HKObject]?, completion: @escaping (Error?) -> Void)
    {
        guard let createOrUpdateObjects = objects,
            createOrUpdateObjects.count > 0 else {
                completion(nil)
                return
        }
        
        // Create an array of external objects from the deleted objects
        let externalObjects = createOrUpdateObjects.compactMap({ self.externalObjectType.externalObject(object: $0, converter: self.converter) })
        
        // Fetch the objects from the external store
        self.fetchExternalObjects(with: externalObjects)
        { (externalObjects, error) in
            
            guard error == nil else
            {
                completion(error)
                return
            }
            
            if let types = self.externalObjectType.authorizationTypes() as? [HKQuantityType]
            {
                self.store.preferredUnits(for: Set(types), completion:
                    { (unitsDictionary, error) in
                    
                        // Try to fetch the preferred units for objects.
                        self.unitsDictionary = unitsDictionary
                        self.applyUpdates(objects: createOrUpdateObjects, existingObjects: externalObjects, completion: completion)
                })
            }
            else
            {
                self.applyUpdates(objects: createOrUpdateObjects, existingObjects: externalObjects, completion: completion)
            }
        }
    }
    
    private func applyUpdates(objects: [HKObject], existingObjects: [HDSExternalObjectProtocol]?, completion: @escaping (Error?) -> Void)
    {
        if let externalObjects = self.externalObjects(from: objects, existingObjects: existingObjects)
        {
            if (externalObjects.add.count > 0)
            {
                self.externalObjectStore.add(objects: externalObjects.add, completion:
                    { error in
                    
                        guard error == nil else
                        {
                            completion(error)
                            return
                        }
                        
                        if (externalObjects.update.count > 0)
                        {
                            self.externalObjectStore.update(objects: externalObjects.update, completion: completion)
                        }
                        else
                        {
                            completion(error)
                        }
                })
                return
            }
            else if (externalObjects.update.count > 0)
            {
                self.externalObjectStore.update(objects: externalObjects.update, completion: completion)
                return
            }
        }
        
        completion(nil)
    }
    
    private func fetchExternalObjects(with objects: [HDSExternalObjectProtocol]?, completion: @escaping ([HDSExternalObjectProtocol]?, Error?) -> Void)
    {
        if (objects != nil && !objects!.isEmpty)
        {
            self.externalObjectStore.fetchObjects(with: objects!, completion: completion)
            return
        }
        
        completion(nil, nil)
    }
    
    private func externalObjects(from objects: [HKObject], existingObjects: [HDSExternalObjectProtocol]?) -> (add: [HDSExternalObjectProtocol], update: [HDSExternalObjectProtocol])?
    {
        var add = [HDSExternalObjectProtocol]()
        var update = [HDSExternalObjectProtocol]()
        
        objects.forEach(
            { (object) in
                
                var isUpdate = false
                
                existingObjects?.forEach(
                    { (existingObject) in
                        
                        if (object.uuid == existingObject.uuid)
                        {
                            isUpdate = true
                            existingObject.update(with: object)
                            update.append(existingObject)
                        
                            return
                        }
                })
                
                // Create a new external object
                if (!isUpdate)
                {
                    if let newExternalObject = self.externalObjectType.externalObject(object: object, converter: self.converter)
                    {
                        add.append(newExternalObject)
                    }
                }
        })
        
        return (add.count < 1 && update.count < 1) ? nil : (add, update)
    }
    
    // MARK: Subclass overrides
    
    // Subclasses can override to execute code to BEFORE requests to the external store are made.
    open func willSyncronize(objects: [HKObject]?, deletedObjects: [HKDeletedObject]?, completion:@escaping () -> Void)
    {
        completion()
    }
    
    // Subclasses can override to execute code to AFTER requests to the external store are made.
    open func willFinishSyncronizing(after completion:@escaping () -> Void)
    {
        completion()
    }
}
