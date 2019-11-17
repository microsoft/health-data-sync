//
//  MockPermissionsManager.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockPermissionsManager : HDSPermissionsManager {
    public var authorizeHealthKitCompletions = [(success: Bool, error: Error?)]()
    
    open override func authorizeHealthKit(_ completion: @escaping (Bool, Error?) -> Void) {
        let comp = authorizeHealthKitCompletions.removeFirst()
        completion(comp.success, comp.error)
    }
}
