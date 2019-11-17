//
//  HDSError.swift
//  HealthDataSync
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public enum HDSError : Error
{
    case unavailable
    case noSpecifiedTypes
    case notSupported
    case operationCancelled
}
