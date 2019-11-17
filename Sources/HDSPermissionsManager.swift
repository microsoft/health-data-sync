//
//  HDSPermissionsManager
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

#if os(iOS)

import Foundation
import HealthKit

open class HDSPermissionsManager
{
    // Properties
    public var readTypes = [HKObjectType]()
    public var shareTypes = [HKSampleType]()
    private let store: HDSStoreProxyProtocol
    
    // Initializer
    public init(store: HDSStoreProxyProtocol)
    {
        self.store = store
    }
    
    open func authorizeHealthKit(_ completion:@escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        // HealthKit not available (for e.g. on iPad)
        if (!self.store.isHealthDataAvailable())
        {
            print("HealthKit is not available on the current device!")
            completion(false, HDSError.unavailable)
            return
        }
        
        // Empty Read and Write Types
        if (self.readTypes.isEmpty && self.shareTypes.isEmpty)
        {
            print("HealthKit read and write types were empty!")
            completion(false, HDSError.noSpecifiedTypes)
            return
        }
        
        // Get read and write object types to authorize.
        let readTypes: Set<HKObjectType> =  Set(self.readTypes)
        let shareTypes: Set<HKSampleType> = Set(self.shareTypes)
        
        print("Requesting authorization to read and write types")
        
        self.store.requestAuthorization(toShare: shareTypes, read: readTypes)
        {(success, error) -> Void in

            print((success ? "HealthKit authorization succeeded!" : "HealthKit authorization failed!"))
            
            if let authError = error
            {
                // Error exists.
                print(authError)
            }
            
            completion(success, error)
        }
    }
}

#endif
