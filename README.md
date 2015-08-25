![ModelRocket](https://s3.amazonaws.com/f.cl.ly/items/272x3d230n0Z3T300V1D/model-rocket.jpg)

![Build Status](https://travis-ci.org/ovenbits/ModelRocket.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Cocoapods Compatible](https://img.shields.io/cocoapods/v/ModelRocket.svg)
![License](https://img.shields.io/badge/license-MIT-000000.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

An iOS framework for creating JSON-based models. Written in Swift (because [it totally rules!](https://youtu.be/Qq_NuyR8XPg?t=36s))

## Requirements

- iOS 7.0+
- Xcode 7 beta 6+
- Swift 2

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8**

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```

To integrate ModelRocket into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ogdl
github "ovenbits/ModelRocket"
```

Then, run `carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for up-to-date installation instructions.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ModelRocket into your Xcode project using CocoaPods, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ModelRocket'
```

Then, run `pod install`.

## Usage

### Creating a custom object

```swift
class Vehicle: ModelRocket {
	let make  = Property<String>(key: "make")
	let model = Property<String>(key: "model", required: true)
	let year  = Property<Int>(key: "year") { year in
		if year < 2015 {
			// offer discount
		}
	}
	let color = Property<UIColor>(key: "color", defaultValue: UIColor.blackColor())
}
```
> NOTE: As with all Swift variables, `let` should always be used, unless `var` is absolutely needed. In the case of ModelRocket objects, `let` should be used for all `Property[Array|Dictionary]` properties, as it still allows the underlying `value` to be changed, unless you truly need to reassign the property

#### Supported Types

- `String`
- `Bool`
- `Int`
- `UInt`
- `Double`
- `Float`

In addition to the core types above, ModelRocket also supports serialization for several other
classes out of the box:

- `NSDate` &mdash; ISO8601-formatted string (`2015-05-31T19:00:17+00:00`)
- `UIColor` &mdash; hex-color string (`#f6c500`)
- `NSURL` &mdash; any url string (`http://ovenbits.com`)
- `NSNumber` &mdash; any number, can be used in place of `Double`, `Float`, `Int`, and `UInt`

### Creating an object with a typed array

```swift
class Vehicles: ModelRocket {
    let vehicles = PropertyArray<Vehicle>(key: "vehicles")
}
```

`PropertyArray` conforms to `CollectionType`, therefore, the `.values` syntax is not necessary when iterating through the values. For example:

```swift
let allVehicles = Vehicles(json: <json>)

// using `.values` syntax
for vehicle in allVehicles.vehicles.values {
}

// using `CollectionType` conformance
for vehicle in allVehicles.vehicles {
}
```

### Creating an object with a typed dictionary

```swift
class Car: Vehicle {
	let purchasedTrims = PropertyDictionary<Int>(key: "purchased_trims")
}
```

`PropertyDictionary` conforms to `CollectionType`, therefore, the `.values` syntax is not necessary when iterating through the keys and values. For example: 

```swift
let vehicle = Vehicle(json: <json>)

// using `.values` syntax
for (key, trim) in vehicle.purchasedTrims.values {
}

// using `CollectionType` conformance
for (key, trim) in vehicle.purchasedTrims {
}
```

> NOTE: All object in the dictionary must be of the same type. If they're not, the app won't crash, but values of different types will be discarded

### Initializing and using a custom object

```swift
// instantiate object
let vehicle = Vehicle(json: json)

// get property type
println("Vehicle make property has type: \(vehicle.make.type)")

// get property value
if let make = vehicle.make.value {
	println("Vehicle make: \(make)")
}
```

ModelRocket objects also contain a failable initializer, which will only return an initialized object if all properties marked as `required = true` are non-nil.

```swift
// instantiate object, only if `json` contains a value for the `make` property
if let vehicle = Vehicle(strictJSON: json) {
	// it's best to avoid implicitly unwrapped optionals, however, since `vehicle` is initialized iff `make` is non-nil, if can be force-unwrapped safely here
	println("Vehicle make: \(vehicle.make.value!)")
}
else {
	pintln("Invalid JSON")
}
```

### Subclassing a custom object

```swift
class Car: Vehicle {
    let numberOfDoors = Property<Int>(key: "number_of_doors")
}
```

### Adding a custom object as a property of another object

The custom object must conform to the JSONTransformable protocol by defining the following variables/functions

- class func fromJSON(json: JSON) -> T?
- func toJSON() -> AnyObject


```swift
class Vehicle: ModelRocket {
	let manufacturer = Property<Manufacturer>(key: "manufacturer")
}

class Manufacturer: ModelRocket {
    let companyName = Property<String>(key: "company_name")
    let headquarters = Property<String>(key: "headquarters")
    let founded = Property<NSDate>(key: "founded")
}

extension Manufacturer: JSONTransformable {
    class func fromJSON(json: JSON) -> Manufacturer? {
        return Manufacturer(json: json)
    }
    func toJSON() -> AnyObject {
        return self.json().dictionary
    }
}
```

### Property `postProcess` hook

The `Property` `postProcess` closure (also available on `PropertyArray` and `PropertyDictionary`) provides a mechanism for work to be done after all properties of a `ModelRocket` object have been initialized from JSON but before the `ModelRocket` object has finished initializing. 


```swift
class Vehicles: ModelRocket {
    let vehicles = PropertyArray<Vehicle>(key: "vehicles") { (values) -> Void in
        for vehicle in values {
            println("postHook vehicle: \(vehicle.make.value!)")
        }
    }
}
```


### `.value` accessor usage pattern

A ModelRocket property is of type `Property<T>`. When accessing the property's value, you go through `Property.value`, e.g.:
  
```swift
let vehicleMake = make.value
```

It is perfectly acceptable to to utilize `Property`s and access the property `value` directly. However, you may want a different public API for your model objects.

```swift
private let _make = Property<String>(key: "make")
public var make: String {
  get {
    return make.value ?? "unknown make"
  }
  set {
    make.value = newValue
  }
}
```  

This usage pattern enables:

- A cleaner public API
- A public API that makes the type more proper: we expect "make" to be a string, not a `Property`
- `value` is optional because it must be for general applicability, but your API may be more correct to have non-optional. Of course, if your API wants an optional, that's fine too.
- The ability to process or convert the raw JSON value to other values more proper to your object's public API
- Whereas a `Property.value` could be set, you could omit the set accessor for a read-only property, again helping to expose exactly the API for your object that you desire.
- This usage of the bridge pattern enables ModelRocket to become an implementation detail and minimize dependencies and long-term maintenance.


### Implementing a class cluster
Override the `modelForJSON(json: JSON) -> ModelRocket` function

```swift
class Vehicle: ModelRocket {
    let make = Property<String>(key: "make")
    let model = Property<String>(key: "model")
    let year = Property<Int>(key: "year")
    let color = Property<UIColor>(key: "color")
    let manufacturer = Property<Manufacturer>(key: "manufacturer")
    
    override class func modelForJSON(json: JSON) -> ModelRocket {
        
        switch json["type"].string {
        case .Some("car"):
            return Car(json: json)
        case .Some("plane"):
            return Plane(json: json)
        case .Some("bike"):
            return Bike(json: json)
        default:
            return Vehicle(json: json)
        }
    }
}
```

Then to access subclass-specific properties, use a switch-case

```swift
let vehicle = Vehicle.modelForJSON(vehicleJSON)
                
switch vehicle {
case let car as Car:
	// drive the car
case let plane as Plane:
	// fly the plane
case let bike as Bike:
	// ride the bike
default:
	// do nothing
}
```

### Obtaining the object's JSON representation

Calling the `json()` function on a ModelRocket subclass returns a tuple containing:

- `dictionary: [String : AnyObject]`
- `json: JSON`
- `data: NSData`

### Obtaining a copy of a custom object

Call `copy()` on the object, and cast to the correct type. Example:

```swift
let vehicleCopy = vehicle.copy() as! Vehicle
```

## License

ModelRocket is released under the MIT license. See LICENSE for details.