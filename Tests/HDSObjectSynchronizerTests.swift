//
//  HDSObjectSynchronizerTests.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import HealthKit
import Quick
import Nimble

class HDSObjectSynchronizerSpec: QuickSpec {
    override func spec() {
        describe("HDSObjectSynchronizer") {
            context("synchronize is called") {
                context("with nil objects") {
                    context("nil deleted objects") {
                        let test = testObjects()
                        waitUntil { completed in
                            test.synchronizer.synchronize(objects: nil, deletedObjects: nil, completion: { (error) in
                                it("does not return an error") {
                                    expect(error).to(beNil())
                                }
                                it("did not call fetchObjects") {
                                    expect(test.externalStore.fetchObjectsParams.count) == 0
                                }
                                it("did not call delete") {
                                    expect(test.externalStore.deleteParams.count) == 0
                                }
                                it("did not call preferredUnits") {
                                    expect(test.store.preferredUnitsParams.count) == 0
                                }
                                it("did not call update") {
                                    expect(test.externalStore.updateParams.count) == 0
                                }
                                it("did not call add") {
                                    expect(test.externalStore.addParams.count) == 0
                                }
                                completed()
                            })
                        }
                    }
                }
                context("with no objects") {
                    context("no deleted objects") {
                        let test = testObjects()
                        waitUntil { completed in
                            test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 0), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                it("does not return an error") {
                                    expect(error).to(beNil())
                                }
                                it("did not call fetchObjects") {
                                    expect(test.externalStore.fetchObjectsParams.count) == 0
                                }
                                it("did not call delete") {
                                    expect(test.externalStore.deleteParams.count) == 0
                                }
                                it("did not call preferredUnits") {
                                    expect(test.store.preferredUnitsParams.count) == 0
                                }
                                it("did not call update") {
                                    expect(test.externalStore.updateParams.count) == 0
                                }
                                it("did not call add") {
                                    expect(test.externalStore.addParams.count) == 0
                                }
                                completed()
                            })
                        }
                    }
                }
                context("with one object") {
                    context("no deleted objects") {
                        context("fetch is succesful") {
                            context("no fetch objects") {
                                context("preferredUnits is successful") {
                                    context("add is successful") {
                                        let test = testObjects()
                                        test.externalStore.fetchObjecsCompletions.append((nil, nil))
                                        test.externalStore.addCompletions.append(nil)
                                        waitUntil { completed in
                                            test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                                it("does not return an error") {
                                                    expect(error).to(beNil())
                                                }
                                                it("called fetchObjects") {
                                                    expect(test.externalStore.fetchObjectsParams.count) == 1
                                                    expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                                }
                                                it("did not call delete") {
                                                    expect(test.externalStore.deleteParams.count) == 0
                                                }
                                                it("called preferredUnits") {
                                                    expect(test.store.preferredUnitsParams.count) == 1
                                                    expect(test.store.preferredUnitsParams[0].count) == 1
                                                }
                                                it("did not call update") {
                                                    expect(test.externalStore.updateParams.count) == 0
                                                }
                                                it("called add") {
                                                    expect(test.externalStore.addParams.count) == 1
                                                }
                                                completed()
                                            })
                                        }
                                    }
                                    context("add fails") {
                                        let test = testObjects()
                                        test.externalStore.fetchObjecsCompletions.append((nil, nil))
                                        test.externalStore.addCompletions.append(MockError.addFailure)
                                        waitUntil { completed in
                                            test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                                it("returns the error") {
                                                    expect(error).toNot(beNil())
                                                    expect(error).to(matchError(MockError.addFailure))
                                                }
                                                it("called fetchObjects") {
                                                    expect(test.externalStore.fetchObjectsParams.count) == 1
                                                    expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                                }
                                                it("did not call delete") {
                                                    expect(test.externalStore.deleteParams.count) == 0
                                                }
                                                it("called preferredUnits") {
                                                    expect(test.store.preferredUnitsParams.count) == 1
                                                    expect(test.store.preferredUnitsParams[0].count) == 1
                                                }
                                                it("did not call update") {
                                                    expect(test.externalStore.updateParams.count) == 0
                                                }
                                                it("called add") {
                                                    expect(test.externalStore.addParams.count) == 1
                                                    expect(test.externalStore.addParams[0].count) == 1
                                                }
                                                completed()
                                            })
                                        }
                                    }
                                }
                                context("preferredUnits fails") {
                                    let test = testObjects()
                                    test.externalStore.fetchObjecsCompletions.append((nil, nil))
                                    test.store.preferredUnitsCompletions.append(([:], MockError.preferredUnitsFailure))
                                    test.externalStore.addCompletions.append(nil)
                                    waitUntil { completed in
                                        test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                            it("does not return an error") {
                                                expect(error).to(beNil())
                                            }
                                            it("called fetchObjects") {
                                                expect(test.externalStore.fetchObjectsParams.count) == 1
                                                expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                            }
                                            it("did not call delete") {
                                                expect(test.externalStore.deleteParams.count) == 0
                                            }
                                            it("called preferredUnits") {
                                                expect(test.store.preferredUnitsParams.count) == 1
                                                expect(test.store.preferredUnitsParams[0].count) == 1
                                            }
                                            it("did not call update") {
                                                expect(test.externalStore.updateParams.count) == 0
                                            }
                                            it("called add") {
                                                expect(test.externalStore.addParams.count) == 1
                                                expect(test.externalStore.addParams[0].count) == 1
                                            }
                                            completed()
                                        })
                                    }
                                }
                            }
                            context("one fetch object") {
                                context("update is successful") {
                                    let test = testObjects()
                                    let objects = TestHelpers.healthKitObjects(count: 1)
                                    let externalObject = MockExternalObject.externalObject(object: objects[0], converter: nil)!
                                    test.externalStore.fetchObjecsCompletions.append(([externalObject], nil))
                                    test.externalStore.updateCompletions.append(nil)
                                    waitUntil { completed in
                                        test.synchronizer.synchronize(objects: objects, deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                            it("does not return an error") {
                                                expect(error).to(beNil())
                                            }
                                            it("called fetchObjects") {
                                                expect(test.externalStore.fetchObjectsParams.count) == 1
                                                expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                            }
                                            it("did not call delete") {
                                                expect(test.externalStore.deleteParams.count) == 0
                                            }
                                            it("called preferredUnits") {
                                                expect(test.store.preferredUnitsParams.count) == 1
                                                expect(test.store.preferredUnitsParams[0].count) == 1
                                            }
                                            it("called update") {
                                                expect(test.externalStore.updateParams.count) == 1
                                            }
                                            it("did not call add") {
                                                expect(test.externalStore.addParams.count) == 0
                                            }
                                            completed()
                                        })
                                    }
                                }
                                context("update fails") {
                                    let test = testObjects()
                                    let objects = TestHelpers.healthKitObjects(count: 1)
                                    let externalObject = MockExternalObject.externalObject(object: objects[0], converter: nil)!
                                    test.externalStore.fetchObjecsCompletions.append(([externalObject], nil))
                                    test.externalStore.updateCompletions.append(MockError.updateFailure)
                                    waitUntil { completed in
                                        test.synchronizer.synchronize(objects: objects, deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                            it("returns the error") {
                                                expect(error).toNot(beNil())
                                                expect(error).to(matchError(MockError.updateFailure))
                                            }
                                            it("called fetchObjects") {
                                                expect(test.externalStore.fetchObjectsParams.count) == 1
                                                expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                            }
                                            it("did not call delete") {
                                                expect(test.externalStore.deleteParams.count) == 0
                                            }
                                            it("called preferredUnits") {
                                                expect(test.store.preferredUnitsParams.count) == 1
                                                expect(test.store.preferredUnitsParams[0].count) == 1
                                            }
                                            it("called update") {
                                                expect(test.externalStore.updateParams.count) == 1
                                                expect(test.externalStore.updateParams[0].count) == 1
                                            }
                                            it("did not call add") {
                                                expect(test.externalStore.addParams.count) == 0
                                            }
                                            completed()
                                        })
                                    }
                                }
                            }
                        }
                        context("fetch fails") {
                            let test = testObjects()
                            test.externalStore.fetchObjecsCompletions.append((nil, MockError.fetchObjectsFailure))
                            test.externalStore.addCompletions.append(nil)
                            waitUntil { completed in
                                test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                    it("returns the error") {
                                        expect(error).toNot(beNil())
                                        expect(error).to(matchError(MockError.fetchObjectsFailure))
                                    }
                                    it("called fetchObjects") {
                                        expect(test.externalStore.fetchObjectsParams.count) == 1
                                        expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                    }
                                    it("did not call delete") {
                                        expect(test.externalStore.deleteParams.count) == 0
                                    }
                                    it("did not call preferredUnits") {
                                        expect(test.store.preferredUnitsParams.count) == 0
                                    }
                                    it("did not call update") {
                                        expect(test.externalStore.updateParams.count) == 0
                                    }
                                    it("did not call add") {
                                        expect(test.externalStore.addParams.count) == 0
                                    }
                                    completed()
                                })
                            }
                        }
                    }
                    context("one deleted object") {
                        context("delete is succesful") {
                            let test = testObjects()
                            let deletedObjects = TestHelpers.healthKitDeletedObjects(count: 1)
                            let externalObject = MockExternalObject.externalObject(deletedObject: deletedObjects[0], converter: nil)!
                            test.externalStore.fetchObjecsCompletions.append(([externalObject], nil))
                            test.externalStore.fetchObjecsCompletions.append((nil, nil))
                            test.externalStore.deleteCompletions.append(nil)
                            test.externalStore.addCompletions.append(nil)
                            waitUntil { completed in
                                test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: deletedObjects, completion: { (error) in
                                    it("does not return an error") {
                                        expect(error).to(beNil())
                                    }
                                    it("called fetchObjects twice") {
                                        expect(test.externalStore.fetchObjectsParams.count) == 2
                                        expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                        expect(test.externalStore.fetchObjectsParams[1].count) == 1
                                    }
                                    it("called delete") {
                                        expect(test.externalStore.deleteParams.count) == 1
                                    }
                                    it("called preferredUnits") {
                                        expect(test.store.preferredUnitsParams.count) == 1
                                        expect(test.store.preferredUnitsParams[0].count) == 1
                                    }
                                    it("did not call update") {
                                        expect(test.externalStore.updateParams.count) == 0
                                    }
                                    it("called add") {
                                        expect(test.externalStore.addParams.count) == 1
                                    }
                                    completed()
                                })
                            }
                        }
                        context("delete fails") {
                            let test = testObjects()
                            let deletedObjects = TestHelpers.healthKitDeletedObjects(count: 1)
                            let externalObject = MockExternalObject.externalObject(deletedObject: deletedObjects[0], converter: nil)!
                            test.externalStore.fetchObjecsCompletions.append(([externalObject], nil))
                            test.externalStore.fetchObjecsCompletions.append((nil, nil))
                            test.externalStore.deleteCompletions.append(MockError.deleteFailure)
                            test.externalStore.addCompletions.append(nil)
                            waitUntil { completed in
                                test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 1), deletedObjects: deletedObjects, completion: { (error) in
                                    it("returns the error") {
                                        expect(error).toNot(beNil())
                                        expect(error).to(matchError(MockError.deleteFailure))
                                    }
                                    it("called fetchObjects") {
                                        expect(test.externalStore.fetchObjectsParams.count) == 1
                                        expect(test.externalStore.fetchObjectsParams[0].count) == 1
                                    }
                                    it("called delete") {
                                        expect(test.externalStore.deleteParams.count) == 1
                                        expect(test.externalStore.deleteParams[0].count) == 1
                                    }
                                    it("called preferredUnits") {
                                        expect(test.store.preferredUnitsParams.count) == 0
                                    }
                                    it("did not call update") {
                                        expect(test.externalStore.updateParams.count) == 0
                                    }
                                    it("called add") {
                                        expect(test.externalStore.addParams.count) == 0
                                    }
                                    completed()
                                })
                            }
                        }
                    }
                }
                context("with 10 Healthkit objects") {
                    context("no fetch objects") {
                        let test = testObjects()
                        test.externalStore.fetchObjecsCompletions.append((nil, nil))
                        test.externalStore.addCompletions.append(nil)
                        waitUntil { completed in
                            test.synchronizer.synchronize(objects: TestHelpers.healthKitObjects(count: 10), deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                it("does not return an error") {
                                    expect(error).to(beNil())
                                }
                                it("called fetchObjects") {
                                    expect(test.externalStore.fetchObjectsParams.count) == 1
                                    expect(test.externalStore.fetchObjectsParams[0].count) == 10
                                }
                                it("did not call delete") {
                                    expect(test.externalStore.deleteParams.count) == 0
                                }
                                it("called preferredUnits") {
                                    expect(test.store.preferredUnitsParams.count) == 1
                                    expect(test.store.preferredUnitsParams[0].count) == 1
                                }
                                it("did not call update") {
                                    expect(test.externalStore.updateParams.count) == 0
                                }
                                it("called add") {
                                    expect(test.externalStore.addParams.count) == 1
                                    expect(test.externalStore.addParams[0].count) == 10
                                }
                                completed()
                            })
                        }
                    }
                    context("10 fetch objects") {
                        let test = testObjects()
                        let objects = TestHelpers.healthKitObjects(count: 10)
                        let existingObjects = objects.compactMap({ MockExternalObject.externalObject(object: $0, converter: nil) })
                        test.externalStore.fetchObjecsCompletions.append((existingObjects, nil))
                        test.externalStore.updateCompletions.append(nil)
                        waitUntil { completed in
                            test.synchronizer.synchronize(objects: objects, deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                it("does not return an error") {
                                    expect(error).to(beNil())
                                }
                                it("called fetchObjects") {
                                    expect(test.externalStore.fetchObjectsParams.count) == 1
                                    expect(test.externalStore.fetchObjectsParams[0].count) == 10
                                }
                                it("did not call delete") {
                                    expect(test.externalStore.deleteParams.count) == 0
                                }
                                it("called preferredUnits") {
                                    expect(test.store.preferredUnitsParams.count) == 1
                                    expect(test.store.preferredUnitsParams[0].count) == 1
                                }
                                it("called update") {
                                    expect(test.externalStore.updateParams.count) == 1
                                    expect(test.externalStore.updateParams[0].count) == 10
                                }
                                it("did not call add") {
                                    expect(test.externalStore.addParams.count) == 0
                                }
                                completed()
                            })
                        }
                    }
                    context("5 fetch objects") {
                        let test = testObjects()
                        var objects = TestHelpers.healthKitObjects(count: 5)
                        let existingObjects = objects.compactMap({ MockExternalObject.externalObject(object: $0, converter: nil) })
                        objects.append(contentsOf: TestHelpers.healthKitObjects(count: 5))
                        test.externalStore.fetchObjecsCompletions.append((existingObjects, nil))
                        test.externalStore.updateCompletions.append(nil)
                        test.externalStore.addCompletions.append(nil)
                        waitUntil { completed in
                            test.synchronizer.synchronize(objects: objects, deletedObjects: TestHelpers.healthKitDeletedObjects(count: 0), completion: { (error) in
                                it("does not return an error") {
                                    expect(error).to(beNil())
                                }
                                it("called fetchObjects") {
                                    expect(test.externalStore.fetchObjectsParams.count) == 1
                                    expect(test.externalStore.fetchObjectsParams[0].count) == 10
                                }
                                it("did not call delete") {
                                    expect(test.externalStore.deleteParams.count) == 0
                                }
                                it("called preferredUnits") {
                                    expect(test.store.preferredUnitsParams.count) == 1
                                    expect(test.store.preferredUnitsParams[0].count) == 1
                                }
                                it("called update") {
                                    expect(test.externalStore.updateParams.count) == 1
                                    expect(test.externalStore.updateParams[0].count) == 5
                                }
                                it("did not called add") {
                                    expect(test.externalStore.addParams.count) == 1
                                    expect(test.externalStore.addParams[0].count) == 5
                                }
                                completed()
                            })
                        }
                    }
                }
            }
        }
    }

    private func testObjects() -> (store: MockStore, externalStore: MockExternalStore, synchronizer: HDSObjectSynchronizer) {
        let mockStore = MockStore()
        let mockExternalStore = MockExternalStore()
        let synchronizer = HDSObjectSynchronizer(externalObjectType: MockExternalObject.self, store: mockStore, externalStore: mockExternalStore)
        return (mockStore, mockExternalStore, synchronizer)
    }
}
