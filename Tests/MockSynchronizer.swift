//
//  MockSynchronizer.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class MockSynchronizer : HDSObjectSynchronizer {
    public var synchronizeCompletions = [Error?]()
    public var synchronizeParams = [(objects: [HKObject]?, deletedObjects: [HKDeletedObject]?)]()
    
    open override func synchronize(objects: [HKObject]?, deletedObjects: [HKDeletedObject]?, completion: @escaping (Error?) -> Void) {
        synchronizeParams.append((objects, deletedObjects))
        let comp = synchronizeCompletions.removeFirst()
        completion(comp)
    }
}
