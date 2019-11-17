//
//  HDSStoreProxy.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class HDSStoreProxy : HDSStoreProxyProtocol
{
    private var store: HKHealthStore
    
    public init(store: HKHealthStore)
    {
        self.store = store;
    }
    
    public func isHealthDataAvailable() -> Bool
    {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    public func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    {
        return self.store.authorizationStatus(for: type)
    }
    
    public func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Swift.Void)
    {
        self.store.requestAuthorization(toShare: typesToShare, read: typesToRead, completion: completion)
    }
    
    public func execute(_ query: HKQuery)
    {
        self.store.execute(query)
    }
    
    public func stop(_ query: HKQuery)
    {
        self.store.stop(query)
    }
    
    public func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping (Bool, Error?) -> Swift.Void)
    {
#if os(iOS)
        self.store.enableBackgroundDelivery(for: type, frequency: frequency, withCompletion: completion)
#else
        completion(false, HealthKitError.notSupported)
#endif
    }

    public func disableBackgroundDelivery(for type: HKObjectType, withCompletion completion: @escaping (Bool, Error?) -> Swift.Void)
    {
#if os(iOS)
        self.store.disableBackgroundDelivery(for: type, withCompletion: completion)
#else
        completion(false, HealthKitError.notSupported)
#endif
    }

    public func disableAllBackgroundDelivery(completion: @escaping (Bool, Error?) -> Swift.Void)
    {
#if os(iOS)
        self.store.disableAllBackgroundDelivery(completion: completion)
#else
        completion(false, HealthKitError.notSupported)
#endif
    }
    
    public func preferredUnits(for quantityTypes: Set<HKQuantityType>, completion: @escaping ([HKQuantityType : HKUnit], Error?) -> Void)
    {
        self.store.preferredUnits(for: quantityTypes, completion: completion)
    }
}
