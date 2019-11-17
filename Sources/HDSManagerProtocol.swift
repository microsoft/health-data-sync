//
//  HDSManagerProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

public protocol HDSManagerProtocol
{
    /// An array of all HDSQueryObservers that have been added to the manager. This includes observers created by calling addObjectTypes() and addSynchronizers()
    var allObservers: [HDSQueryObserver] { get }
    
    /// An object conforming to the HDSQueryObserverDelegate protocol that will handle delegate methods for ALL observers in the allObservers array. Default value is nil.
    var observerDelegate: HDSQueryObserverDelegate? { get set }
    
    /// An object conforming to HDSConverterProtocol that can be used in the conversion of HKObjects to HDSExternalObjectProtocol types.
    var converter: HDSConverterProtocol? { get set }
    
    /// Begins the user authorization process for allowing access to HealthKit data. Calling this method may envoke a system UI if the user has not previousy given permission for ALL data types managed by the observers the allObservers array.
    /// - Note: Calling this method asks HealthKit to authorize access for all HealthKit data types managed by the observers in the allObservers array.
    ///
    /// - Parameter completion: Called after the permissions process has completed.
    /// - Parameter success: A boolean representing whether or not the process completed successfully.
    /// - Parameter error: An error providing information on the failure, or nil if the process completes successfully.
    /// - Returns: nil
    func requestPermissionsForAllObservers(completion:@escaping (_ success: Bool, _ error: Error?) -> Void)
    
    /// Begins the user authorization process for allowing access to HealthKit data managed by a given Observer. Calling this method may envoke a system UI if the user has not previousy given permission for ALL data types managed by the observers.
    /// - Note: HDSQueryObservers do not need to be added to the allObservers collection to use this method.
    ///
    /// - Parameter observers: An array of HDSQueryObservers.
    /// - Parameter completion: Called after the permissions process has completed.
    /// - Parameter success: A boolean representing whether or not the process completed successfully.
    /// - Parameter error: An error providing information on the failure, or nil if the process completes successfully.
    /// - Returns: nil
    func requestPermissions(with observers: [HDSQueryObserver], _ completion:@escaping (_ success: Bool, _ error: Error?) -> Void)
    
    /// Creates a new HDSQueryObserver for each type in the objectTypes array and adds it to the allObservers array.
    ///
    /// - Parameters:
    ///   - objectTypes: an array of HDSExternalObjectProtocol Types
    ///   - externalStore: An object conforming to HDSExternalStoreProtocol - The external store instance will be used to synchronize all types in the objectTypes array.
    /// - Returns: nil
    func addObjectTypes(_ objectTypes: [HDSExternalObjectProtocol.Type], externalStore: HDSExternalStoreProtocol)

    /// Creates a new HDSQueryObserver for each synchronizer in the synchronizers array and adds it to the allObservers array.
    ///
    /// - Parameters:
    ///   - synchronizers: an array of HDSObjectSynchronizerProtocol objects
    /// - Returns: nil
    func addSynchronizers(_ synchronizers: [HDSObjectSynchronizerProtocol])
    
    /// Executes the observer queries for observers in the allObservers array.
    ///
    /// - Returns: nil
    @available(watchOS, unavailable, message: "HDSQueryObservers cannot receive background deliveries on watchOS. Use call exectue() on individual observers instead.")
    func startObserving()

    /// Stops the observer queries for observers in the allObservers array.
    /// - Note: Stopping the observer queries will remove any persisted data stored by an observer (lastSuccessfulExecutionDate, query anchors, and predicates)
    ///
    /// - Returns: nil
    @available(watchOS, unavailable, message: "HDSQueryObservers cannot receive background deliveries on watchOS. Use call exectue() on individual observers instead.")
    func stopObserving()
    
    /// Provides a collection of HKSources for each HDSQueryObserver provided in the observers parameter.
    /// - Note: HDSQueryObservers do not need to be added to the allObservers collection to use this method.
    ///
    /// - Parameters:
    ///   - observers: An array of HDSQueryObserver objects.
    ///   - completion: Called after the process completes. The completion will provide a dictionary mapping each observer with their sources and an array of errors (if an error occurs).
    func sources(for observers: [HDSQueryObserver], completion: @escaping ([HDSQueryObserver : Set<HKSource>], [Error]?) -> Void)
}

#endif
