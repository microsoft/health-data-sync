//
//  MockQueryObserverDelegate.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockQueryObserverDelegate : HDSQueryObserverDelegate {
    public var batchSizeParams = [HDSQueryObserver]()
    public var batchSizeReturns = [Int?]()
    public var shouldExecuteParams = [HDSQueryObserver]()
    public var shouldExecuteCompletions = [Bool]()
    public var didFinishExecutionParams = [(observer: HDSQueryObserver, error: Error?)]()
    
    public func batchSize(for observer: HDSQueryObserver) -> Int? {
        batchSizeParams.append(observer)
        return batchSizeReturns.removeFirst()
    }
    
    public func shouldExecute(for observer: HDSQueryObserver, completion: @escaping (Bool) -> Void) {
        shouldExecuteParams.append(observer)
        let comp = shouldExecuteCompletions.removeFirst()
        completion(comp)
    }
    
    public func didFinishExecution(for observer: HDSQueryObserver, error: Error?) {
        didFinishExecutionParams.append((observer, error))
    }
    
    
}
