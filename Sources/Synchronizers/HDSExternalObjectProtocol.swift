//
//  HDSExternalObjectProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public protocol HDSExternalObjectProtocol
{
    
    /// A unique identifier used to match HealthKit objects and External Objects.
    /// This identifier is used to query both HealthKit and the External Store to perform updates or deletes on objects that were previously synced.
    var uuid: UUID { get set }
    
    /// The HealthKit object type displayed to the user in the authorization UI
    /// In some cases (e.g. blood pressure) a user must authorize each component of blood pressure separately (systolic, diastolic, and heart rate),
    /// but the query will be a single correlation type
    static func authorizationTypes() -> [HKObjectType]?
    
    /// The HealthKit object type used to query HealthKit.
    static func healthKitObjectType() -> HKObjectType?
    
    /// Creates a new External Object populated with data from the HKObject.
    ///
    /// - Parameters:
    ///   - object: An HKObject containing data to be copied to the new External Object.
    ///   - converter: An instance of a custom converter class.
    /// - Returns: A new object conforming to the HDSExternalObjectProtocol populated with the data from the HKObject or nil if the HKObject cannot be processed.
    static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol?
    
    /// Creates a new External Object populated with data from the HKDeletedObject.
    ///
    /// - Parameters:
    ///   - deletedObject: An HKDeletedObject containing data to be copied to the new External Object.
    ///   - converter: An instance of a custom converter class.
    /// - Returns: A new object conforming to the HDSExternalObjectProtocol populated with the data from the HKDeletedObject or nil if the HKDeletedObject cannot be processed.
    static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol?
    
    /// Updates the External Object with data from the HKObject.
    ///
    /// - Parameter object: An HKObject containing data to be copied to the External Object.
    func update(with object: HKObject)
}
