//
//  HDSStoreProxyProtocol.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit

@available(iOS 8.0, watchOS 2.0, *)
public protocol HDSStoreProxyProtocol
{
    /*!
     @method        isHealthDataAvailable
     @abstract      Returns YES if HealthKit is supported on the device.
     @discussion    HealthKit is not supported on all iOS devices.  Using HKHealthStore APIs on devices which are not
     supported will result in errors with the HKErrorHealthDataUnavailable code.  Call isHealthDataAvailable
     before attempting to use other parts of the framework.
     */
    func isHealthDataAvailable() -> Bool
    
    /*!
     @method        authorizationStatusForType:
     @abstract      Returns the application's authorization status for the given object type.
     */
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    
    /*!
     @method        requestAuthorizationToShareTypes:readTypes:completion:
     @abstract      Prompts the user to authorize the application for reading and saving objects of the given types.
     @discussion    Before attempting to execute queries or save objects, the application should first request authorization
     from the user to read and share every type of object for which the application may require access.
     
     The request is performed asynchronously and its completion will be executed on an arbitrary background
     queue after the user has responded.  If the user has already chosen whether to grant the application
     access to all of the types provided, then the completion will be called without prompting the user.
     The success parameter of the completion indicates whether prompting the user, if necessary, completed
     successfully and was not cancelled by the user.  It does NOT indicate whether the application was
     granted authorization.
     */
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Swift.Void)
    
    /*!
     @method        executeQuery:
     @abstract      Begins executing the given query.
     @discussion    After executing a query, the completion, update, and/or results handlers of that query will be invoked
     asynchronously on an arbitrary background queue as results become available.  Errors that prevent a
     query from executing will be delivered to one of the query's handlers.  Which handler the error will be
     delivered to is defined by the HKQuery subclass.
     
     Each HKQuery instance may only be executed once and calling this method with a currently executing query
     or one that was previously executed will result in an exception.
     
     If a query would retrieve objects with an HKObjectType property, then the application must request
     authorization to access objects of that type before executing the query.
     */
    func execute(_ query: HKQuery)
    
    /*!
     @method        stopQuery:
     @abstract      Stops a query that is executing from continuing to run.
     @discussion    Calling this method will prevent the handlers of the query from being invoked in the future.  If the
     query is already stopped, this method does nothing.
     */
    func stop(_ query: HKQuery)
    
    /*!
     @method        enableBackgroundDeliveryForType:frequency:withCompletion:
     @abstract      This method enables activation of your app when data of the type is recorded at the cadence specified.
     @discussion    When an app has subscribed to a certain data type it will get activated at the cadence that is specified
     with the frequency parameter. The app is still responsible for creating an HKObserverQuery to know which
     data types have been updated and the corresponding fetch queries. Note that certain data types (such as
     HKQuantityTypeIdentifierStepCount) have a minimum frequency of HKUpdateFrequencyHourly. This is enforced
     transparently to the caller.
     */
    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping (Bool, Error?) -> Swift.Void)
    
    func disableBackgroundDelivery(for type: HKObjectType, withCompletion completion: @escaping (Bool, Error?) -> Swift.Void)

    func disableAllBackgroundDelivery(completion: @escaping (Bool, Error?) -> Swift.Void)
    
    /*!
     @method        preferredUnitsForQuantityTypes:completion:
     @abstract      Calls the completion with the preferred HKUnits for a given set of HKQuantityTypes.
     @discussion    A preferred unit is either the unit that the user has chosen in Health for displaying samples of the
     given quantity type or the default unit for that type in the current locale of the device. To access the
     user's preferences it is necessary to request read or share authorization for the set of HKQuantityTypes
     provided. If neither read nor share authorization has been granted to the app, then the default unit for
     the locale is provided.
     
     An error will be returned when preferred units are inaccessible because protected health data is
     unavailable or authorization status is not determined for one or more of the provided types.
     
     The returned dictionary will map HKQuantityType to HKUnit.
     */
    @available(iOS 8.2, watchOS 2.0, *)
    func preferredUnits(for quantityTypes: Set<HKQuantityType>, completion: @escaping ([HKQuantityType : HKUnit], Error?) -> Swift.Void)
}
