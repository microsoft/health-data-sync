//
//  TestHelpers.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class TestHelpers {
    
    public static func healthKitObjects(count: Int) -> [HKObject] {
        var objects = [HKObject]()
        
        for _ in 0..<count {
            objects.append(HKQuantitySample.init(type: HKQuantityType.quantityType(forIdentifier: .heartRate)!, quantity: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 76), start: Date(), end: Date()))
        }
        
        return objects
    }
    
    public static func healthKitDeletedObjects(count: Int) -> [HKDeletedObject] {
        var objects = [HKDeletedObject]()
        
        
        
        for i in 0..<count {
            
            do {
                if let path = Bundle(for: TestHelpers.self).path(forResource: "HKDeletedObject\(i + 1)", ofType: nil) {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    if let deletedObject = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKDeletedObject.self, from: data) {
                        objects.append(deletedObject)
                    }
                }
            } catch {
                print(error)
            }
        }
        
        return objects
    }
}
