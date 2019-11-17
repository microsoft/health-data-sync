//
//  MockStore.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

public class MockStore : HDSStoreProxyProtocol {
    public var isHealthDataAvailableValue = true
    public var isHealthDataAvailableCount = 0
    public var authorizationStatusValue = HKAuthorizationStatus.notDetermined
    public var authorizationStatusParams = [HKObjectType]()
    public var requestAuthorizationParams = [(toShare: Set<HKSampleType>?, read: Set<HKObjectType>?)]()
    public var requestAuthorizationCompletions = [(success: Bool, error: Error?)]()
    public var executeParams = [HKQuery]()
    public var stopParams = [HKQuery]()
    public var enableBackgroundDeliveryParams = [(HKObjectType, HKUpdateFrequency)]()
    public var enableBackgroundDeliveryCompletions = [(success: Bool, error: Error?)]()
    public var disableBackgroundDeliveryParams = [HKObjectType]()
    public var disableBackgroundDeliveryCompletions = [(success: Bool, error: Error?)]()
    public var disableAllBackgroundDeliveryCount = 0
    public var disableAllBackgroundDeliveryCompletions = [(success: Bool, error: Error?)]()
    public var preferredUnitsParams = [Set<HKQuantityType>]()
    public var preferredUnitsCompletions = [(dict: [HKQuantityType : HKUnit], error: Error?)]()
    
    public func reset() {
        isHealthDataAvailableValue = true
        isHealthDataAvailableCount = 0
        authorizationStatusValue = HKAuthorizationStatus.notDetermined
        authorizationStatusParams.removeAll()
        requestAuthorizationParams.removeAll()
        requestAuthorizationCompletions.removeAll()
        executeParams.removeAll()
        stopParams.removeAll()
        enableBackgroundDeliveryParams.removeAll()
        enableBackgroundDeliveryCompletions.removeAll()
        disableBackgroundDeliveryParams.removeAll()
        disableBackgroundDeliveryCompletions.removeAll()
        disableAllBackgroundDeliveryCount = 0
        disableAllBackgroundDeliveryCompletions.removeAll()
        preferredUnitsParams.removeAll()
        preferredUnitsCompletions.removeAll()
    }
    
    public func isHealthDataAvailable() -> Bool {
        isHealthDataAvailableCount += 1
        return isHealthDataAvailableValue
    }
    
    public func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        authorizationStatusParams.append(type)
        return authorizationStatusValue
    }
    
    public func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationParams.append((typesToShare, typesToRead))
        let comp = requestAuthorizationCompletions.removeFirst()
        completion(comp.success, comp.error)
    }
    
    public func execute(_ query: HKQuery) {
        executeParams.append(query)
    }
    
    public func stop(_ query: HKQuery) {
        stopParams.append(query)
    }
    
    public func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping (Bool, Error?) -> Void) {
        enableBackgroundDeliveryParams.append((type, frequency))
        let comp = enableBackgroundDeliveryCompletions.removeFirst()
        completion(comp.success, comp.error)
    }
    
    public func disableBackgroundDelivery(for type: HKObjectType, withCompletion completion: @escaping (Bool, Error?) -> Void) {
        disableBackgroundDeliveryParams.append(type)
        let comp = disableBackgroundDeliveryCompletions.removeFirst()
        completion(comp.success, comp.error)
    }
    
    public func disableAllBackgroundDelivery(completion: @escaping (Bool, Error?) -> Void) {
        let comp = disableAllBackgroundDeliveryCompletions.removeFirst()
        completion(comp.success, comp.error)
    }
    
    public func preferredUnits(for quantityTypes: Set<HKQuantityType>, completion: @escaping ([HKQuantityType : HKUnit], Error?) -> Void) {
        preferredUnitsParams.append(quantityTypes)
        
        if preferredUnitsCompletions.count > 0 {
            let comp = preferredUnitsCompletions.removeFirst()
            completion(comp.dict, comp.error)
            return
        }
        
        var dict = [HKQuantityType : HKUnit]()
        for type in quantityTypes {
            dict[type] = HKUnit.init(from: "count")
        }
        
        completion(dict, nil)
    }
}
