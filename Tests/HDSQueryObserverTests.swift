//
//  HDSQueryObserverTests.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import Quick
import Nimble

class HDSQueryObserverSpec: QuickSpec {
    override func spec() {
        describe("HDSQueryObserver") {
            context("start is called") {
                it ("checks the availability of health kit on the device") {
                    let test = self.testObjects()
                    test.queryObserver.start()
                    expect(test.store.isHealthDataAvailableCount) == 1
                }
                it ("checks if the user has authorized the observer type") {
                    let test = self.testObjects()
                    test.queryObserver.start()
                    expect(test.store.authorizationStatusParams.count) == 1
                    expect(test.store.authorizationStatusParams[0]).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                }
                context("health kit is unavailable") {
                    let test = self.testObjects()
                    test.store.isHealthDataAvailableValue = false
                    test.queryObserver.start()
                    it("does not enable background delivery") {
                        expect(test.store.enableBackgroundDeliveryParams.count) == 0
                    }
                    it("does not execute the observer query") {
                        expect(test.store.executeParams.count) == 0
                    }
                    it("does not set isObserving to true") {
                        expect(test.queryObserver.isObserving).to(beFalse())
                    }
                }
                context("the observer type is not determined") {
                    let test = self.testObjects()
                    test.queryObserver.start()
                    it("does not enable background delivery") {
                        expect(test.store.enableBackgroundDeliveryParams.count) == 0
                    }
                    it("does not execute the observer query") {
                        expect(test.store.executeParams.count) == 0
                    }
                    it("does not set isObserving to true") {
                        expect(test.queryObserver.isObserving).to(beFalse())
                    }
                }
                context("the observer type is not authorized") {
                    context("enabling background delivery fails") {
                        let test = self.testObjects()
                        test.store.authorizationStatusValue = .sharingDenied
                        test.store.enableBackgroundDeliveryCompletions.append((false, MockError.enableBackgroundDeliveryFailure))
                        test.userDefaults.dataReturns.append(nil)
                        test.queryObserver.start()
                        waitForCondition(object: test.queryObserver, format: "isObserving == false")
                        it("sets isObserving to false") {
                            expect(test.queryObserver.isObserving).to(beFalse())
                        }
                        it("attempts to enables background delivery") {
                            expect(test.store.enableBackgroundDeliveryParams.count) == 1
                        }
                        it("does not execute the observer query") {
                            expect(test.store.executeParams.count) == 0
                        }
                    }
                    context("enabling background delivery succeeds") {
                        let test = self.testObjects()
                        test.store.authorizationStatusValue = .sharingDenied
                        test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                        test.userDefaults.dataReturns.append(nil)
                        test.queryObserver.start()
                        it("enables background delivery") {
                            expect(test.store.enableBackgroundDeliveryParams.count) == 1
                        }
                        it("executes the observer query") {
                            expect(test.store.executeParams.count) == 1
                            expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                        }
                        it("sets isObserving to true") {
                            expect(test.queryObserver.isObserving).to(beTrue())
                        }
                    }
                }
                context("the observer type is authorized") {
                    context("enabling background delivery fails") {
                        let test = self.testObjects()
                        test.store.authorizationStatusValue = .sharingAuthorized
                        test.store.enableBackgroundDeliveryCompletions.append((false, MockError.enableBackgroundDeliveryFailure))
                        test.userDefaults.dataReturns.append(nil)
                        test.queryObserver.start()
                        waitForCondition(object: test.queryObserver, format: "isObserving == false")
                        it("attempts to enables background delivery") {
                            expect(test.store.enableBackgroundDeliveryParams.count) == 1
                        }
                        it("does not execute the observer query") {
                            expect(test.store.executeParams.count) == 0
                        }
                        it("sets isObserving to true") {
                            expect(test.queryObserver.isObserving).to(beFalse())
                        }
                    }
                    context("enabling background delivery succeeds") {
                        let test = self.testObjects()
                        test.store.authorizationStatusValue = .sharingAuthorized
                        test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                        test.userDefaults.dataReturns.append(nil)
                        test.queryObserver.start()
                        it("enables background delivery") {
                            expect(test.store.enableBackgroundDeliveryParams.count) == 1
                        }
                        it("executes the observer query") {
                            expect(test.store.executeParams.count) == 1
                            expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                        }
                        it("sets isObserving to true") {
                            expect(test.queryObserver.isObserving).to(beTrue())
                        }
                    }
                }
                context("when queryPredicate is set") {
                    let test = self.testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    let expectedPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: HKQueryOptions.strictStartDate)
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.queryObserver.queryPredicate = expectedPredicate
                    test.queryObserver.start()
                    it("executes the observer query using the custom predicate") {
                        expect(test.store.executeParams.count) == 1
                        expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                        expect(test.store.executeParams[0].predicate).to(equal(expectedPredicate))
                    }
                }
            }
            context("stop is called") {
                it ("checks the availability of health kit on the device") {
                    let test = self.testObjects()
                    test.queryObserver.start()
                    expect(test.store.isHealthDataAvailableCount) == 1
                }
                context("health kit is unavailable") {
                    let test = self.testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(nil)
                    test.queryObserver.start()
                    test.store.isHealthDataAvailableValue = false
                    test.queryObserver.stop()
                    it("does not attempt to disable background delivery") {
                        expect(test.store.disableBackgroundDeliveryParams.count) == 0
                    }
                    it("does not attempt to stop the observer query") {
                        expect(test.store.stopParams.count) == 0
                    }
                    it("does not set isObserving to false") {
                        expect(test.queryObserver.isObserving).to(beTrue())
                    }
                    it("does not delete any saved state objects") {
                        expect(test.userDefaults.removeObjectParams.count) == 0
                    }
                }
                context("disabling background delivery fails") {
                    let test = self.testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(nil)
                    test.queryObserver.start()
                    waitForCondition(object: test.queryObserver, format:"isObserving == true")
                    test.store.disableBackgroundDeliveryCompletions.append((false, MockError.disableBackgroundDeliveryFailure))
                    test.queryObserver.stop()
                    it("calls disable background delivery") {
                        expect(test.store.disableBackgroundDeliveryParams.count) == 1
                    }
                    it("calls stop with the observer query") {
                        expect(test.store.stopParams.count) == 1
                    }
                    it("sets isObserving to false") {
                        expect(test.queryObserver.isObserving).to(beFalse())
                    }
                    it("deletes the saved state objects") {
                        expect(test.userDefaults.removeObjectParams.count) == 3
                        expect(test.userDefaults.removeObjectParams).to(contain(["HKQuantityTypeIdentifierHeartRate-Predicate", "HKQuantityTypeIdentifierHeartRate-Anchor", "HKQuantityTypeIdentifierHeartRate-Last-Execution-Date"]))
                    }
                }
                context("disabling background delivery succeeds") {
                    let test = self.testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(nil)
                    test.queryObserver.start()
                    waitForCondition(object: test.queryObserver, format:"isObserving == true")
                    test.store.disableBackgroundDeliveryCompletions.append((true, nil))
                    test.queryObserver.stop()
                    it("calls disable background delivery") {
                        expect(test.store.disableBackgroundDeliveryParams.count) == 1
                    }
                    it("calls stop with the observer query") {
                        expect(test.store.stopParams.count) == 1
                    }
                    it("sets isObserving to false") {
                        expect(test.queryObserver.isObserving).to(beFalse())
                    }
                    it("deletes the saved state objects") {
                        expect(test.userDefaults.removeObjectParams.count) == 3
                        expect(test.userDefaults.removeObjectParams).to(contain(["HKQuantityTypeIdentifierHeartRate-Predicate", "HKQuantityTypeIdentifierHeartRate-Anchor", "HKQuantityTypeIdentifierHeartRate-Last-Execution-Date"]))
                    }
                }
            }
            context("execute is called") {
                let test = self.testObjects()
                test.queryObserver.execute(completion: { (success, error) in })
                it("executes the anchored object query") {
                    expect(test.store.executeParams.count) == 1
                    expect(test.store.executeParams[0]).to(beAKindOf(HKAnchoredObjectQuery.self))
                    expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                }
                context("when queryPredicate is set") {
                    let test = self.testObjects()
                    let expectedPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: HKQueryOptions.strictStartDate)
                    test.queryObserver.queryPredicate = expectedPredicate
                    test.queryObserver.execute(completion: { (success, error) in })
                    it("executes the anchored object query") {
                        expect(test.store.executeParams.count) == 1
                        expect(test.store.executeParams[0]).to(beAKindOf(HKAnchoredObjectQuery.self))
                        expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                    }
                    it("includes the custom predicate") {
                        expect(test.store.executeParams[0].predicate).to(equal(expectedPredicate))
                    }
                }
                context("a delegate is set") {
                    context("shouldExecute returns false") {
                        let test = self.testObjects()
                        let delegate = MockQueryObserverDelegate()
                        delegate.shouldExecuteCompletions.append(false)
                        test.queryObserver.delegate = delegate
                        waitUntil { completed in
                            test.queryObserver.execute(completion: { (success, error) in
                                it("completes unsuccessfully") {
                                    expect(success).to(beFalse())
                                }
                                it("returns an operation cancelled error") {
                                    expect(error).to(matchError(HDSError.operationCancelled))
                                }
                                completed()
                            })
                        }
                    }
                    context("shouldExecute returns true") {
                        let test = self.testObjects()
                        let delegate = MockQueryObserverDelegate()
                        delegate.shouldExecuteCompletions.append(true)
                        delegate.batchSizeReturns.append(100)
                        test.queryObserver.delegate = delegate
                        test.queryObserver.execute(completion: { (success, error) in })
                        it("executes the anchored object query") {
                            expect(test.store.executeParams.count) == 1
                            expect(test.store.executeParams[0]).to(beAKindOf(HKAnchoredObjectQuery.self))
                            expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                        }
                        it("calls batchSize on the delegate") {
                            expect(delegate.batchSizeParams.count) == 1
                            expect(delegate.batchSizeParams[0]) == test.queryObserver
                        }
                    }
                }
            }
            context("when when queryPredicate is set") {
                let test = self.testObjects()
                let expectedPredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: HKQueryOptions.strictStartDate)
                test.queryObserver.queryPredicate = expectedPredicate
                it("saves the predicate") {
                    expect(test.userDefaults.setParams.count) == 1
                    expect(test.userDefaults.setParams[0].defaultName) == "HKQuantityTypeIdentifierHeartRate-Predicate"
                }
            }
        }
    }
    
    private func testObjects() -> (store: MockStore, externalStore: MockExternalStore, userDefaults: MockUserDefaults, synchronizer: MockSynchronizer, queryObserver: HDSQueryObserver) {
        let mockStore = MockStore()
        let mockExternalStore = MockExternalStore()
        let mockUserDefaults = MockUserDefaults()
        let mockSynchronizer = MockSynchronizer(externalObjectType: MockExternalObject.self, store: mockStore, externalStore: mockExternalStore)
        let queryObserver = HDSQueryObserver(store: mockStore, userDefaultsProxy: mockUserDefaults, synchronizer: mockSynchronizer)
        return (mockStore, mockExternalStore, mockUserDefaults, mockSynchronizer, queryObserver)
    }
}
