//
//  HDSManagerTests.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import Quick
import Nimble

class HDSManagerSpec: QuickSpec {
    override func spec() {
        describe("HDSManager") {
            context("requestPermissionsForAllObservers is called") {
                context("permissionsManager error unavailable") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((false, HDSError.unavailable))
                    waitUntil { completed in
                        test.manager.requestPermissionsForAllObservers(completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the error") {
                                expect(error).to(matchError(HDSError.unavailable))
                            }
                            completed()
                        })
                    }
                }
                context("permissionsManager error noSpecifiedTypes") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((false, HDSError.noSpecifiedTypes))
                    waitUntil { completed in
                        test.manager.requestPermissionsForAllObservers(completion: { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the error") {
                                expect(error).to(matchError(HDSError.noSpecifiedTypes))
                            }
                            completed()
                        })
                    }
                }
                context("is successful") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((true, nil))
                    waitUntil { completed in
                        test.manager.requestPermissionsForAllObservers(completion: { (success, error) in
                            it("complete with success") {
                                expect(success).to(beTrue())
                            }
                            it("returns no error") {
                                expect(error).to(beNil())
                            }
                            completed()
                        })
                    }
                }
            }
            context("requestPermissions with observers is called") {
                context("permissionsManager error unavailable") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((false, HDSError.unavailable))
                    waitUntil { completed in
                        test.manager.requestPermissions(with: [], { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the error") {
                                expect(error).to(matchError(HDSError.unavailable))
                            }
                            completed()
                        })
                    }
                }
                context("permissionsManager error noSpecifiedTypes") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((false, HDSError.noSpecifiedTypes))
                    waitUntil { completed in
                        test.manager.requestPermissions(with: [], { (success, error) in
                            it("completes unsuccessfully") {
                                expect(success).to(beFalse())
                            }
                            it("returns the error") {
                                expect(error).to(matchError(HDSError.noSpecifiedTypes))
                            }
                            completed()
                        })
                    }
                }
                context("is successful") {
                    let test = testObjects()
                    test.permissionsManager.authorizeHealthKitCompletions.append((true, nil))
                    waitUntil { completed in
                        test.manager.requestPermissions(with: [], { (success, error) in
                            it("complete with success") {
                                expect(success).to(beTrue())
                            }
                            it("returns no error") {
                                expect(error).to(beNil())
                            }
                            completed()
                        })
                    }
                }
            }
            context("addObjectTypes and external store is called") {
                context("with an empty array") {
                    let test = testObjects()
                    test.manager.addObjectTypes([], externalStore: MockExternalStore())
                    it("has and empty allObservers collection") {
                        expect(test.manager.allObservers.count) == 0
                    }
                }
                context("with a single type") {
                    let test = testObjects()
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: MockExternalStore())
                    it("creates an observer and adds it to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 1
                    }
                    it("creates the expected type of observer") {
                        expect(test.manager.allObservers[0].externalObjectType).to(be(MockExternalObject.self))
                    }
                }
                context("with 2 types") {
                    let test = testObjects()
                    test.manager.addObjectTypes([MockExternalObject.self, MockExternalObject2.self], externalStore: MockExternalStore())
                    it("creates an observer for each type and adds them to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 2
                    }
                    it("creates the expected types of observers") {
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject.self })).to(beTrue())
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject2.self })).to(beTrue())
                    }
                }
                context("with a type that already exists in the allObservers collection") {
                    let test = testObjects()
                    let mockExternalStore = MockExternalStore()
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: mockExternalStore)
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: mockExternalStore)
                    it("does not create another observer") {
                        expect(test.manager.allObservers.count) == 1
                    }
                }
                context("twice with different types") {
                    let test = testObjects()
                    let mockExternalStore = MockExternalStore()
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: mockExternalStore)
                    test.manager.addObjectTypes([MockExternalObject2.self], externalStore: mockExternalStore)
                    it("creates an observer for each type and adds them to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 2
                    }
                    it("creates the expected types of observers") {
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject.self })).to(beTrue())
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject2.self })).to(beTrue())
                    }
                }
            }
            context("addSynchronizers is called") {
                context("with an empty array") {
                    let test = testObjects()
                    test.manager.addSynchronizers([])
                    it("has and empty allObservers collection") {
                        expect(test.manager.allObservers.count) == 0
                    }
                }
                context("with a single synchronizer") {
                    let test = testObjects()
                    let synchronizer = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: test.store, externalStore: MockExternalStore())
                    test.manager.addSynchronizers([synchronizer])
                    it("creates an observer and adds it to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 1
                    }
                    it("creates the expected type of observer") {
                        expect(test.manager.allObservers[0].externalObjectType).to(be(MockExternalObject.self))
                    }
                }
                context("with 2 synchronizers") {
                    let test = testObjects()
                    let mockExternalStore = MockExternalStore()
                    let synchronizer = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: test.store, externalStore: mockExternalStore)
                    let synchronizer2 = HDSObjectSynchronizer(externalObjectType: MockExternalObject2.self, store: test.store, externalStore: mockExternalStore)
                    test.manager.addSynchronizers([synchronizer, synchronizer2])
                    it("creates an observer for each synchronizer and adds them to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 2
                    }
                    it("creates the expected types of observers") {
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject.self })).to(beTrue())
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject2.self })).to(beTrue())
                    }
                }
                context("with a synchronizer that is already represented in the allObservers collection") {
                    let test = testObjects()
                    let mockExternalStore = MockExternalStore()
                    let synchronizer = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: test.store, externalStore: mockExternalStore)
                    let synchronizer2 = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: test.store, externalStore: mockExternalStore)
                    test.manager.addSynchronizers([synchronizer])
                    test.manager.addSynchronizers([synchronizer2])
                    it("does not create another observer") {
                        expect(test.manager.allObservers.count) == 1
                    }
                }
                context("twice with different synchronizers") {
                    let test = testObjects()
                    let mockExternalStore = MockExternalStore()
                    let synchronizer = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: test.store, externalStore: mockExternalStore)
                    let synchronizer2 = HDSObjectSynchronizer(externalObjectType: MockExternalObject2.self, store: test.store, externalStore: mockExternalStore)
                    test.manager.addSynchronizers([synchronizer])
                    test.manager.addSynchronizers([synchronizer2])
                    it("creates an observer for each synchronizer and adds them to the allObservers collection") {
                        expect(test.manager.allObservers.count) == 2
                    }
                    it("creates the expected types of observers") {
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject.self })).to(beTrue())
                        expect(test.manager.allObservers.contains(where: { $0.externalObjectType == MockExternalObject2.self })).to(beTrue())
                    }
                }
            }
            context("startObserving is called") {
                context("when no observers have been added") {
                    let test = testObjects()
                    test.manager.startObserving()
                    it("does nothing") {
                        _ = succeed()
                    }
                }
                context("when one observer has been added") {
                    let test = testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(nil)
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: MockExternalStore())
                    test.manager.startObserving()
                    it("calls start on the observer") {
                        expect(test.store.enableBackgroundDeliveryParams.count) == 1
                    }
                }
                context("when two observers have been added") {
                    let test = testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(contentsOf: [nil, nil])
                    test.manager.addObjectTypes([MockExternalObject.self, MockExternalObject2.self], externalStore: MockExternalStore())
                    test.manager.startObserving()
                    it("calls start on the observer") {
                        expect(test.store.enableBackgroundDeliveryParams.count) == 2
                    }
                }
            }
            context("stopObserving is called") {
                context("when no observers have been added") {
                    let test = testObjects()
                    test.manager.stopObserving()
                    it("does nothing") {
                        _ = succeed()
                    }
                }
                context("when one observer has been added") {
                    let test = testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.store.disableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(contentsOf: [nil, nil])
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: MockExternalStore())
                    test.manager.startObserving()
                    waitForCondition(object: test.manager.allObservers[0], format:"isObserving == true")
                    test.manager.stopObserving()
                    it("calls stop on the observer") {
                        expect(test.store.disableBackgroundDeliveryParams.count).toEventually(equal(1))
                    }
                }
                context("when two observers have been added") {
                    let test = testObjects()
                    test.store.authorizationStatusValue = .sharingAuthorized
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.store.enableBackgroundDeliveryCompletions.append((true, nil))
                    test.store.disableBackgroundDeliveryCompletions.append((true, nil))
                    test.store.disableBackgroundDeliveryCompletions.append((true, nil))
                    test.userDefaults.dataReturns.append(contentsOf: [nil, nil, nil, nil])
                    test.manager.addObjectTypes([MockExternalObject.self, MockExternalObject2.self], externalStore: MockExternalStore())
                    test.manager.startObserving()
                    waitForCondition(object: test.manager.allObservers[0], format:"isObserving == true")
                    test.manager.stopObserving()
                    it("calls stop on the observer") {
                        expect(test.store.disableBackgroundDeliveryParams.count) == 2
                    }
                }
            }
            context("sources for observers is called") {
                context("with an empty array") {
                    let test = testObjects()
                    waitUntil { completed in
                        test.manager.sources(for: [], completion: { (dict, errors) in
                            it("returns an empty sources dictionary") {
                                expect(dict.count) == 0
                            }
                            it("returns no errors") {
                                expect(errors!.count) == 0
                            }
                            completed()
                        })
                    }
                }
                context("with a single observer") {
                    let test = testObjects()
                    test.manager.addObjectTypes([MockExternalObject.self], externalStore: MockExternalStore())
                    test.manager.sources(for: test.manager.allObservers, completion: { (dict, errors) in })
                    it("calls execute on the store") {
                        expect(test.store.executeParams.count) == 1
                    }
                    it("contains the expected type") {
                        expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                    }
                }
                context("with a two observers") {
                    let test = testObjects()
                    test.manager.addObjectTypes([MockExternalObject.self, MockExternalObject2.self], externalStore: MockExternalStore())
                    test.manager.sources(for: test.manager.allObservers, completion: { (dict, errors) in })
                    it("calls execute on the store twice") {
                        expect(test.store.executeParams.count) == 2
                    }
                    it("contains the expected types") {
                        expect(test.store.executeParams[0].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .heartRate)))
                        expect(test.store.executeParams[1].objectType).to(equal(HKObjectType.quantityType(forIdentifier: .stepCount)))
                    }
                }
            }
        }
    }
    
    private func testObjects() -> (store: MockStore, userDefaults: MockUserDefaults, permissionsManager: MockPermissionsManager, manager: HDSManager) {
        let mockStore = MockStore()
        let mockUserDefaults = MockUserDefaults()
        let mockPermissionsManager = MockPermissionsManager(store: mockStore)
        let observerFactory = HDSQueryObserverFactory(store: mockStore, userDefaults: mockUserDefaults)
        let manager = HDSManager(store: mockStore, userDefaults: mockUserDefaults, permissionsManager: mockPermissionsManager, observerFactory: observerFactory)
        return (mockStore, mockUserDefaults, mockPermissionsManager, manager)
    }
}
