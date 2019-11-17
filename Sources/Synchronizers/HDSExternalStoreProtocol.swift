//
//  HDSExternalStoreProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public protocol HDSExternalStoreProtocol
{
    
    /// Will be called to fetch objects from an external store.
    ///
    /// - Parameters:
    ///   - objects: A collection of objects conforming to HDSExternalObjectProtocol used to fetch the externally stored objects.
    ///   - completion: MUST be called once the operation is completed and provide objects conforming to the HDSExternalObjectProtocol (if any) or an Error object if the operation fails.
    /// - Important: It is assuemd that any objects returned in the completion exist in the external store and will be updated NOT created.
    /// - Returns: void
    func fetchObjects(with objects: [HDSExternalObjectProtocol], completion: @escaping ([HDSExternalObjectProtocol]? , Error?) -> Void)
    
    /// Will be called to add new objects to an external store.
    ///
    /// - Parameters:
    ///   - objects: Objects conforming to HDSExternalObjectProtocol.
    ///   - completion: MUST be called when the operation has completed. An Error should be provided if the operation fails.
    /// - Returns: void
    func add(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)
    
    /// Will be called to update existing objects in an external store
    ///
    /// - Parameters:
    ///   - objects: Objects conforming to HDSExternalObjectProtocol.
    ///   - completion: MUST be called when the operation has completed. An Error should be provided if the operation fails.
    /// - Returns: void
    func update(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)
    
    /// Will be called to delete existing objects from an external store
    ///
    /// - Parameters:
    ///   - deletedObjects: A collection of objects conforming to HDSExternalObjectProtocol used to delete externally stored objects.
    ///   - completion: MUST be called when the operation has completed. An Error should be provided if the operation fails.
    /// - Returns: void
    func delete(deletedObjects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)
}
