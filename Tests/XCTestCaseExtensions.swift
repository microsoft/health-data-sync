//
//  XCTestCaseExtensions.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import XCTest

extension XCTestCase {
    public func waitForCondition(object: Any, format: String, _ args: CVarArg...) {
        let predicate = NSPredicate(format: format, args)
        let ex = expectation(for: predicate, evaluatedWith: object, handler: nil)
        _ = XCTWaiter.wait(for: [ex], timeout: 2)
    }
}
