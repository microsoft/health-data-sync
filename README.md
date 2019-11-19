# HealthDataSync Swift Library

[![Build Status](https://microsofthealth.visualstudio.com/Health/_apis/build/status/POET/HealthDataSync_Daily?branchName=master)](https://microsofthealth.visualstudio.com/Health/_build/latest?definitionId=431&branchName=master)

HealthDataSync is a Swift library that simplifies and automates the export of HealthKit data to an external store. The most basic usage requires the implementation of just two protocols:

* HDSExternalStoreProtocol - An object that handles the connection to an external store with basic CRUD functionality.
* HDSExternalObjectProtocol - An implementation of the data transport object used to send data to the external store.

Once the required protocols have been implemented, the HDSManager can be initialized and used to request permissions from the user to access the specified HealthKit data types defined in the HDSExternalObjectProtocol; start and stop the underlying HKObserverQuery that will observe changes to the specified HealthKit data types and call back to your application when changes occur; and execute the underlying HKAnchoredObjectQuery to fetch changes in the requested HealthKit data and synchronize them with your HDSExternalStoreProtocol implementation.

## Installation

HealthDataSync uses **Swift Package Manager** to manage dependencies. It is recommended that you use Xcode 11 or newer to add HealthDataSync to your project.

1. Using Xcode 11 go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/microsoft/health-data-sync
3. Click on next and select the project target

## Basic Implementation

### Implement HDSExternalStoreProtocol

When changes to observed HealthKit data types occur, the HealthDataSync library will call back to your "external store" to handle the changes. The synchronization process begins by checking if the data has already been synchronized by calling the fetchObjects() function (the call to fetch objects happens regardless of whether the change(s) in HealthKit data were creates, updates, or deletes).

If the change is NOT a DELETE, if the "external store" returns an array of HDSExternalObjectProtocol objects, the update() function will be called to update the instance(s) of HDSExternalObjectProtocol using the new HealthKit data. If no HDSExternalObjectProtocol objects are returned, the add() function will be called to add a new instance(s) of HealthKit Data.

For deleted HealthKit data, if the "external store" returns an array of HDSExternalObjectProtocol objects, the delete() function will be called to delete the data stored externally. However, if no HDSExternalObjectProtocol objects are returned, the delete() function will NOT be called.

```swift
public protocol HDSExternalStoreProtocol
{
    /// Will be called to fetch objects from an external store.
    func fetchObjects(with objects: [HDSExternalObjectProtocol], completion: @escaping ([HDSExternalObjectProtocol]? , Error?) -> Void)

    /// Will be called to add new objects to an external store.
    func add(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)

    /// Will be called to update existing objects in an external store
    func update(objects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)

    /// Will be called to delete existing objects from an external store
    func delete(deletedObjects: [HDSExternalObjectProtocol], completion: @escaping (Error?) -> Void)
}
```

### Implement HDSExternalObjectProtocol

The HDSExternalObjectProtocol defines an object type that is used to map HealthKit HKObjects to an instance of a DTO used to synchronize with an external store.

The HDSManager uses the authorizationTypes() to obtain read consent from the user when authorization functions are called and healthKitObjectType() is used to create an HKObserverQuery and an HKAnchoredObjectQuery to monitor changes in HealthKit data.

During the synchronization process, static functions are called to initialize new HDSExternalObjectProtocol objects with an HKObject or an HKDeletedObject. If the operation is an update, the update function will be called on the instance.

```swift
public protocol HDSExternalObjectProtocol
{
    /// A unique identifier used to match HealthKit objects and External Objects.
    var uuid: UUID { get set }

    /// The HealthKit object type displayed to the user in the authorization UI.
    static func authorizationTypes() -> [HKObjectType]?

    /// The HealthKit object type used to query HealthKit.
    static func healthKitObjectType() -> HKObjectType?

    /// Creates a new External Object populated with data from the HKObject.=
    static func externalObject(object: HKObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol?

    /// Creates a new External Object populated with data from the HKDeletedObject.
    static func externalObject(deletedObject: HKDeletedObject, converter: HDSConverterProtocol?) -> HDSExternalObjectProtocol?

    /// Updates the External Object with data from the HKObject.
    func update(with object: HKObject)
}
 ```

### Initialize an instance of HDSManager and create observers using the external object and external store

For simplicity, the HDSManagerFactory class can be used to create a singleton HDSManager. Once on observer is created by calling addObjectTypes() passing the type of HDSExternalObjectProtocol you implemented and your implementation of HDSExternalStoreProtocol the manager is ready to be used.

**Important: The HDSManager must be initialized in the AppDelegate application:didFinishLaunchingWithOptions: function to handle changes in HealthKit when the application is not running.**

```swift
// Get the HDSManager.
let manager = HDSManagerFactory.manager()

// Initialize an instance of your external store.
let externalStore = ExampleExternalStore()

// Create observers by calling addObjectTypes.
manager.addObjectTypes(ExampleExternalObject.self, externalStore: ExampleExternalStore)
```

The HDSManager is now ready to be used. The application can ask the user to grant permission for access to HealthKit:

```swift
manager.requestPermissionsForAllObservers(completion: { (success, error) in })
```

The application can start observing changes in HealthKit:

```swift
manager.startObserving()
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

There are many other ways to contribute to the HealthDataSync Project.

* [Submit bugs](https://github.com/microsoft/health-data-sync/issues) and help us verify fixes as they are checked in.
* Review the [source code changes](https://github.com/microsoft/health-data-sync/pulls).
* [Contribute bug fixes](CONTRIBUTING.md).

See [Contributing to HealthDataSync](CONTRIBUTING.md) for more information.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
