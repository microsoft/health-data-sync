//
//  HDSConverterProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

public protocol HDSConverterProtocol
{
    /// Converts a HealthKit HKObject to a specific destination type.
    ///
    /// - Parameter object: The HealthKit HKObject to convert.
    /// - Returns: A new instance of the destination object created from the HealthKit HKObject.
    /// - Throws: If there is an error during the conversion process.
    func convert<T>(object: HKObject) throws -> T
    
    /// Converts a HealthKit HKDeletedObject to a specific destination type.
    ///
    /// - Parameter object: The HealthKit HKDeletedObject to convert.
    /// - Returns: A new instance of the destination object created from the HealthKit HKDeletedObject.
    /// - Throws: If there is an error during the conversion process.
    func convert<T>(deletedObject: HKDeletedObject) throws -> T
}

#endif
