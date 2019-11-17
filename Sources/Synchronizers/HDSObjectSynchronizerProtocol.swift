//
//  HDSObjectSynchronizerProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public protocol HDSObjectSynchronizerProtocol
{
    
    /// A custom converter that handles the conversion of HealthKit types.
    var converter: HDSConverterProtocol? { get set }
    
    /// The external object type the used by the synchronizer to convert HealthKit objects to a format compatible with the external store.
    var externalObjectType: HDSExternalObjectProtocol.Type { get }
    
    /// Synchronizes a objects with an external store.
    ///
    /// - Parameters:
    ///   - objects: HealthKit objects to be updated or created.
    ///   - deletedObjects: HealthKit objects to be deleted.
    ///   - completion: Envoked when the synchronization process completed.
    func synchronize(objects: [HKObject]?, deletedObjects: [HKDeletedObject]?, completion: @escaping (Error?) -> Void)
}
