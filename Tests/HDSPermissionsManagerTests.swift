//
//  HDSPermissionsManagerTests.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import Quick
import Nimble

class HDSPermissionsManagerSpec: QuickSpec {
    override func spec() {
        describe("HDSPermissionsManager") {
            context("authorizeHealthKit is called") {
                context("when health kit is not available on the device") {
                    let test = testObjects()
                    test.store.isHealthDataAvailableValue = false
                    waitUntil { completed in
                        test.permissionsManager.authorizeHealthKit { (success, error) in
                            it("fails with the expected error") {
                                expect(success).to(beFalse())
                                expect(error).to(matchError(HDSError.unavailable))
                            }
                            completed()
                        }
                    }
                }
                context("when readTypes and shareTypes is not set") {
                    let test = testObjects()
                    waitUntil { completed in
                        test.permissionsManager.authorizeHealthKit { (success, error) in
                            it("fails with the expected error") {
                                expect(success).to(beFalse())
                                expect(error).to(matchError(HDSError.noSpecifiedTypes))
                            }
                            completed()
                        }
                    }
                }
                context("when readTypes and shareTypes are set") {
                    let test = testObjects()
                    let type = HKObjectType.quantityType(forIdentifier: .heartRate)!
                    let type2 = HKObjectType.quantityType(forIdentifier: .stepCount)!
                    let type3 = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
                    test.permissionsManager.readTypes = [type, type2, type3]
                    test.permissionsManager.shareTypes = [type, type2, type3]
                    test.store.requestAuthorizationCompletions.append((true, nil))
                    waitUntil { completed in
                        test.permissionsManager.authorizeHealthKit { (success, error) in
                            it("completes successfully") {
                                expect(success).to(beTrue())
                            }
                            it("does note return an error") {
                                expect(error).to(beNil())
                            }
                            it("calls the store with the expected types") {
                                expect(test.store.requestAuthorizationParams.count) == 1
                                expect(test.store.requestAuthorizationParams[0].toShare?.count) == 3
                                expect(test.store.requestAuthorizationParams[0].read?.count) == 3
                            }
                            completed()
                        }
                    }
                }
            }
        }
    }
    
    private func testObjects() -> (store: MockStore, permissionsManager: HDSPermissionsManager) {
        let mockStore = MockStore()
        let permissionsManager = HDSPermissionsManager(store: mockStore)
        return (mockStore, permissionsManager)
    }
}
