//
//  HDSQueryObserverDelegate.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public protocol HDSQueryObserverDelegate: class
{
    
    /// The maximum number of samples the given HDSQueryObserver will fetch in the anchored query. If the number of changes is > than the batchLimit, queries will be recursively executed until all changes are synchronized.
    ///
    /// - Parameter observer: The HDSQueryObserver that was notified of changes.
    /// - Returns: The number of changes that should be included in the query result. (If nil, the default value of 25 will be used.
    func batchSize(for observer: HDSQueryObserver) -> Int?
    
    /// Will be called when the HDSQueryObserver is notified of changes relating to the query, before the execution of the anchored query.
    ///
    /// - Parameters:
    ///   - observer: The HDSQueryObserver that was notified of changes.
    ///   - completion: Must be called to start the execution of the anchored query and subsequent synchronization with the external store. Return true to start the execution and false to cancel.
    func shouldExecute(for observer: HDSQueryObserver, completion: @escaping (Bool) -> Void)
    
    /// Will be called after execution of the anchor query AND synchronization with the external store has completed.
    ///
    /// - Parameters:
    ///   - observer: The HDSQueryObserver that finished execution.
    ///   - error: An Error providing data on an execution or synchronization failure (error will be nil if the process completed successfully).
    func didFinishExecution(for observer: HDSQueryObserver, error: Error?)
}

public extension HDSQueryObserverDelegate
{
    func batchSize(for observer: HDSQueryObserver) -> Int?
    {
        return Constants.defaultBatchSize
    }
    
    func shouldExecute(for observer: HDSQueryObserver, completion: @escaping (Bool) -> Void)
    {
        completion(true)
    }
    
    func didFinishExecution(for observer: HDSQueryObserver, error: Error?)
    {
        
    }
}
