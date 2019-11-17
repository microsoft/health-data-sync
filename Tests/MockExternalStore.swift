//
//  MockExternalStore.swift
//  HealthDataSync_Tests
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation

public class MockExternalStore : HDSExternalStoreProtocol {
    public var fetchObjectsParams = [[HDSExternalObjectProtocol]]()
    public var fetchObjecsCompletions = [(objects: [HDSExternalObjectProtocol]?, error: Error?)]()
    public var addParams = [[HDSExternalObjectProtocol]]()
    public var addCompletions = [Error?]()
    public var updateParams = [[HDSExternalObjectProtocol]]()
    public var updateCompletions = [Error?]()
    public var deleteParams = [[HDSExternalObjectProtocol]]()
    public var deleteCompletions = [Error?]()
    
    public func reset() {
        fetchObjectsParams.removeAll()
        fetchObjecsCompletions.removeAll()
        addParams.removeAll()
        addCompletions.removeAll()
        updateParams.removeAll()
        updateCompletions.removeAll()
        deleteParams.removeAll()
        deleteCompletions.removeAll()
    }
    
    public func fetchObjects(with objects: [HDSExternalObjectProtocol], completion: @escaping ([HDSExternalObjectProtocol]?, Error?) -> Void) {
        fetchObjectsParams.append(objects)
        let comp = fetchObjecsCompletions.removeFirst()
        completion(comp.objects, comp.error)
    }
    
    public func add(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        addParams.append(objects)
        let error = addCompletions.removeFirst()
        completion(error)
    }
    
    public func update(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        updateParams.append(objects)
        let error = updateCompletions.removeFirst()
        completion(error)
    }
    
    public func delete(deletedObjects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void) {
        deleteParams.append(deletedObjects)
        let error = deleteCompletions.removeFirst()
        completion(error)
    }
}
