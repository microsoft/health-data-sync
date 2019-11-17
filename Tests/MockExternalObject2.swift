//
//  MockExternalObject2.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class MockExternalObject2 : HDSExternalObjectProtocol {
    public var updateCount = 0
    public var externalObjectParams: (object: HKObject, converter: HDSConverterProtocol?)?
    public var externalObjectDeletedParams: (deletedObject: HKDeletedObject, converter: HDSConverterProtocol?)?
    
    public var uuid = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    
    public static func authorizationTypes() -> [HKObjectType]? {
        return [HKObjectType.quantityType(forIdentifier: .stepCount)!]
    }
    
    public static func healthKitObjectType() -> HKObjectType? {
        return HKObjectType.quantityType(forIdentifier: .stepCount)
    }
    
    public static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        let externalObject = MockExternalObject2()
        externalObject.uuid = object.uuid
        externalObject.externalObjectParams = (object, converter)
        return externalObject
    }
    
    public static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol? {
        let externalObject = MockExternalObject2()
        externalObject.uuid = deletedObject.uuid
        externalObject.externalObjectDeletedParams = (deletedObject, converter)
        return externalObject
    }
    
    public func update(with object: HKObject) {
        updateCount += 1
    }
}
