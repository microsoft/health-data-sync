//
//  MockExternalObject.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class MockExternalObject : HDSExternalObjectProtocol {
    public var updateCount = 0
    public var externalObjectParams: (object: HKObject, converter: HDSConverterProtocol?)?
    public var externalObjectDeletedParams: (deletedObject: HKDeletedObject, converter: HDSConverterProtocol?)?
    
    public var uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    public static func authorizationTypes() -> [HKObjectType]? {
        return [HKObjectType.quantityType(forIdentifier: .heartRate)!]
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .heartRate)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        let externalObject = MockExternalObject()
        externalObject.uuid = object.uuid
        externalObject.externalObjectParams = (object, converter)
        return externalObject
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        let externalObject = MockExternalObject()
        externalObject.uuid = deletedObject.uuid
        externalObject.externalObjectDeletedParams = (deletedObject, converter)
        return externalObject
    }
    
    public func update(with object: HKObject) {
        updateCount += 1
    }
}
