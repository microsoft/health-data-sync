//
//  MockError.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum MockError : Error {
    case fetchObjectsFailure
    case addFailure
    case updateFailure
    case deleteFailure
    case preferredUnitsFailure
    case enableBackgroundDeliveryFailure
    case disableBackgroundDeliveryFailure
}
